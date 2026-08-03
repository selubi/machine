<!-- CLAUDE.md -->
# Agent notes for this repo

User-facing usage lives in [README.md](./README.md). This file is the stuff that is
not obvious from reading the code, plus the traps that have already bitten.

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

### Let apps own their own state

Deliberate stance, applied consistently:

- `programs.vscode.mutableExtensionsDir = true` — VSCode installs its own extensions.
- `programs.plasma.overrideConfig = false` — KDE keeps its runtime state (panel UUIDs,
  window positions, tiling, HDR calibration) in the same files we write.

Same price both times: **deleting a setting from this repo leaves the key behind.** Nix
stops asserting it, nix does not clean it up. Remove orphans by hand.

## Traps

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
