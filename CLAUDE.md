<!-- CLAUDE.md -->
# Agent notes for this repo

User-facing usage lives in [README.md](./README.md). This file is the stuff that is
not obvious from reading the code, plus the traps that have already bitten.

**Keep this file current.** Agents should update it as they go — new traps, new
conventions, corrections to things written here that turned out wrong — without waiting
to be asked. Same for anything you learn about how selubi likes to work (comment style,
what to verify vs. assert, how much to ask before acting): if it'll matter to the next
agent working in this repo, write it down here, not just in your own memory.

## What this is

Standalone (not NixOS-module) home-manager flake, currently applied to CachyOS with
KDE Plasma 6. `targets.genericLinux.enable` is on for non-NixOS targets. KDE itself is
the system's (`/usr/bin/kwin_wayland`), not from nix — only the *config* is declarative.

## Layout

| path | role |
|---|---|
| `flake.nix` | inputs, and the module list every home configuration gets |
| `global-config-input.nix` / `global-config-derived.nix` | target definitions and derived `nixContext` |
| `home/core/` | username, homedir, stateVersion, `NXM_*` session vars |
| `home/features/*.nix` | one topic each; imports the modules it needs and adds its own config |
| `home/modules/*.nix` | one program each |
| `home/users/<name>/default.nix` | picks which features that user gets |
| `home/files/` | static files copied out via `xdg.configFile`/`home.file` |

Features import modules freely; duplicate imports of the same path are fine, the module
system dedupes them. A feature owning its own dependency is preferred over relying on
another feature to have imported it.

## Conventions

- Every file opens with a `# path/to/file.nix` comment.
- `nixfmt` is the formatter. Run `nixfmt --check <files>` before claiming done; let it
  decide line breaks rather than hand-wrapping.
- **Comments carry weight here.** They explain *why*, link the resources that were
  actually used, and list the commands to debug the thing (`wev`, `xkbcli`,
  `/usr/share/X11/xkb/rules/base.lst`). Prose is plain and conversational, uses "we",
  and prefers a numbered list of rejected alternatives over a dense clause. When a
  decision looks arbitrary but isn't, say "don't simplify this back" and give the reason.
  State the settled conclusion, not the investigation that got you there — no "confirmed
  by running X", no "I initially assumed Y which was wrong". `home/features/japanese-input.nix`
  is the reference for the target density; keep new comments closer to that than not.
- `home.stateVersion = "26.05"` in `home/core/default.nix` — never change it.

### Guard options that come from flake inputs

Options provided by external modules (`catppuccin`, `programs.plasma`) are wrapped so a
configuration that omits the module degrades instead of failing to evaluate:

```nix
config = lib.optionalAttrs (options ? programs.plasma) { programs.plasma = { ... }; };
```

**`lib.mkIf` does not work for this.** Verified: it defers the *value* but still submits
the attribute path as a definition, so evaluation dies with
``error: The option `programs.plasma' does not exist``. Only `optionalAttrs` drops the
attrs before the module system sees them. See `home/features/theme.nix`,
`home/modules/plasma.nix`, `home/features/japanese-input.nix`.

Cost of the guard: silent degradation. Say so in a comment where it matters.

### Cross-feature defaults: `options.defaultX.{package,desktopId}`

When a feature picks a concrete app for a role (`browser.nix` → Chrome, `code-editor.nix`
→ VSCode, `terminal-emulator.nix` → ghostty), it exposes a small `readOnly` option pair
— `defaultBrowser.package`/`.desktopId`, `defaultEditor.*`, `defaultTerminal.*` — instead
of having every other feature that needs "the browser"/"the editor" read
`config.programs.<specific-app>.*` directly. Consumers (`mail.nix`, `calendar.nix`,
`gui.nix`) import the feature that owns the option and read it, same as any other
"feature owns its own dependency" import. Swapping the underlying app later only means
changing the one file that sets the option.

### Let apps own their own state

Deliberate stance, applied consistently:

- `programs.vscode.mutableExtensionsDir = true` — VSCode installs its own extensions.
- `programs.plasma.overrideConfig = false` — KDE keeps its runtime state (panel UUIDs,
  window positions, tiling, HDR calibration) in the same files we write.

Same price both times: **deleting a setting from this repo leaves the key behind.** Nix
stops asserting it, nix does not clean it up. Remove orphans by hand.

**`programs.plasma.panels` is the deliberate exception.** Setting it at all makes
plasma-manager take full ownership of panels — see the Trap below. `home/features/gui.nix`
opts into this on purpose to get a reproducible dock/top-bar layout; everywhere else in
this repo, panels/desktop state is still left alone.

## Traps

### `programs.plasma.panels` replaces panels wholesale, not merges

Its layout script opens with `panels().forEach(panel => panel.remove())`, then recreates
only what's declared in nix. Any panel/widget you add live in the GUI after this is set
gets destroyed on the next apply — this is the one place plasma-manager does not merge
into existing KDE state. See `home/features/gui.nix`.

### KDE has two separate "default application" mechanisms

System Settings → Default Applications looks like one thing but isn't. Browser/Terminal
resolve through legacy singular keys in `kdeglobals` (`BrowserApplication=`,
`TerminalApplication=`) — confirmed live, but not read or written by the current
`kcm_componentchooser.so` (grepped it directly, neither string appears). Email/Calendar/
TextEditor/FileManager resolve through plain XDG mimetype associations
(`xdg.mimeApps.defaultApplications`) instead — `text/calendar`, `x-scheme-handler/mailto`,
etc. Don't assume one mechanism covers all four categories just because the KCM shows
them on the same page. `home/features/gui.nix` sets the two kdeglobals keys directly;
`browser.nix`/`mail.nix`/`calendar.nix`/`code-editor.nix` set mimeapps.

### A `.desktop` file id is not always unambiguous, and don't derive it via `readDir`

Multiple features expose `options.defaultX.desktopId` (`browser.nix`, `code-editor.nix`,
`terminal-emulator.nix`) as a plain hardcoded string rather than reading it off the
package (`builtins.readDir "${pkg}/share/applications"`). Two reasons: that needs the
package already built at *eval* time (an import-from-derivation, slow and a Nix flakes
anti-pattern), and it isn't even always unambiguous — `google-chrome`'s package ships
*two* `.desktop` files (`com.google.Chrome.desktop` and `google-chrome.desktop`), so
"the" filename depends on which one the rest of the config already assumes. Verify once
by hand instead: `ls $(nix eval --raw '.#homeConfigurations."selubi@selupc".config.programs.<x>.package')/share/applications`.

### A changed generation hash does not mean a changed config

`global-config-derived.nix` sets `sha = flake.rev or flake.dirtyRev`, which feeds
`NXM_SHA` in `home/core/default.nix`. So **any** uncommitted edit flips `NXM_SHA` from
`<rev>` to `<rev>-dirty`, which rewrites `hm-session-vars.sh` → `config.fish` → and
cascades into man-cache and fontconfig-cache paths. The generation hash changes for a
purely cosmetic edit.

Do not use the generation hash to judge whether behaviour changed. Diff the artifact you
actually care about — for plasma, the `data.json` referenced by the `plasma-config`
script (recipe below).

### Flake eval needs files git-tracked

A new `.nix` file makes eval fail with `Path '...' in the repository ... is not tracked
by Git`. Fix with `git add -N <file>` (intent-to-add is enough) and leave it staged, or
the user's next `nxm` hits the same error.

### `//` is a shallow update

`{ a.x = 1; } // { a.y = 2; }` evaluates to `{ a = { y = 2; }; }` — `a.x` is gone, with no
error. It only works when both sides have disjoint *top-level* attrs, and note
`xdg.configFile.foo = …` desugars so the top-level key is `xdg`. `theme.nix` relies on
this holding. For module `config` with several blocks, prefer `lib.mkMerge`, which is the
module system's own type-aware merge; the guarded block still needs `optionalAttrs` inside it.

## Verification recipes

Building proves evaluation, not behaviour. These check behaviour without applying:

```bash
# formatting + evaluation
nixfmt --check <files>
nix build --no-link '.#homeConfigurations."selubi@selupc".activationPackage'

# read a computed value instead of guessing
nix eval --raw '.#homeConfigurations."selubi@selupc".config.home.profileDirectory'
```

**Does a guard actually work?** Evaluate the module twice, with and without the flake
module, using a stub base (do not `extendModules` the real config — it hits
`global-config-derived.nix`'s `dirtyRev` and fails for unrelated reasons):

```nix
mk = extra: f.inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [ ./home/features/<feature>.nix
              { home.username = "selubi"; home.homeDirectory = "/home/selubi";
                home.stateVersion = "26.05"; } ] ++ extra;
};
```

**What will plasma-manager actually write?** It merges into existing files, so diff its
output against copies of the live ones rather than guessing. Get `data.json` from
`nix-store -q --references <plasma-config script>`, rewrite the absolute paths in it to a
temp dir, run plasma-manager's `script/write_config.py` there, and `diff` against
`~/.config/*`. This caught that only one line of `kwinrc` changes and the HDR/tiling keys
survive.

**What will `programs.plasma.panels`/`configFile` actually write?** `nix build` prints the
derivations it's building — find the one for the panel layout script or `data.json`, then
resolve and read it directly:

```bash
nix build --no-link --print-out-paths '.#homeConfigurations."selubi@selupc".activationPackage'
# copy the relevant .drv path from the build output, then:
P=$(nix-store -q --outputs <path>.drv | head -1)
grep 'writeConfig("launchers"' "$P"   # or whatever key you're checking
```

This is how the dock launcher list, the per-sensor colors, and the `kdeglobals`
`BrowserApplication`/`TerminalApplication` values all got confirmed in this repo —
cheaper than applying and checking live, and catches nix-level mistakes (wrong widget
name, wrong option shape) before they ever reach `nxm`.

**Is it live, not just on disk?** KDE reads most of this at session start. For input
methods: `ps -eo pid,ppid,comm | grep fcitx5` — its parent should be `kwin_wayland`, which
proves KWin launched it from the `kwinrc` setting. `qdbus6 org.kde.KWin /VirtualKeyboard
org.freedesktop.DBus.Properties.Get org.kde.kwin.VirtualKeyboard available` → `true` means
KWin resolved the desktop-file path. For xkb: `xkbcli compile-keymap --layout us --options
<opt> | grep -A6 'key <CAPS>'` picks up `~/.config/xkb` automatically and shows the
compiled symbols.

## Applying

`nxm` (alias from `home/features/machine-update.nix`) runs
`nh <targetType> switch --refresh -a -b backup -c <targetName>`. Changes to keyboard,
input method, cursors and fcitx5 generally need a relogin to take effect.

Applying rewrites the user's live desktop config, so treat it like a commit: confirm
first. `.claude/settings.json` has `ask` rules for `nxm`/`nh * switch`/`hms` for this reason.
