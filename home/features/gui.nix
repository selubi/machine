# home/features/gui.nix
{
  options,
  lib,
  config,
  ...
}:
{
  # The dock launchers below need calendar/mail/browser/editor/terminal's
  # .desktop entries and defaultX.desktopId options to exist, so this feature
  # owns those imports itself rather than counting on default.nix to have
  # pulled them in. Imports dedupe by path, so no harm where they're already
  # imported elsewhere too.
  imports = [
    ./calendar.nix
    ./mail.nix
    ./browser.nix
    ./code-editor.nix
    ./terminal-emulator.nix
  ];

  config = lib.mkMerge [
    {
      qt = {

        # Kvantum is styled in ./theme.nix
        enable = true;
        kvantum = {
          enable = true;
        };
        style.name = "kvantum";

        # explore this later. this crashes systemsettings.
        # platformTheme.name = "kde";
      };
    }

    # Guard, don't crash if plasma-manager is not available. Same trick as
    # home/modules/plasma.nix -- lib.mkIf does NOT work here, it still submits
    # the `programs.plasma` attribute path to the module system even when the
    # branch is false, and eval dies with "option does not exist". Only
    # optionalAttrs drops it before the module system ever sees it.
    (lib.optionalAttrs (options ? programs.plasma) {
      # Panel layout: a centered icon-only dock (bottom) plus a
      # Hyprland-waybar-style top bar.
      #
      # Setting `programs.plasma.panels` at all makes plasma-manager take
      # full ownership of panels -- its layout script removes every existing
      # panel first, then recreates only what's listed here. Deliberate
      # exception to this repo's usual "let apps own their own state" stance
      # (see modules/plasma.nix); panels don't get that treatment once you
      # opt in.

      # BrowserApplication/TerminalApplication are legacy kdeglobals keys,
      # not read by the current Default Applications KCM -- that KCM (and
      # Email/Calendar/TextEditor) resolves through plain XDG mimetype
      # associations instead, already covered by mail.nix/calendar.nix. These
      # two are kept because something else still reads them (most likely
      # `preferred://` in task manager, or "Open Terminal Here" in Dolphin),
      # and would otherwise silently outlive any nix generation.
      programs.plasma.configFile.kdeglobals.General = {
        BrowserApplication = config.defaultBrowser.desktopId;
        TerminalApplication = "${lib.getExe config.defaultTerminal.package}";
      };

      programs.plasma.panels = [
        # Icon-only task manager, floating and sized to content rather than
        # stretched full-width -- `floating + lengthMode "fit"` gets you that
        # without needing spacer widgets. "dodgewindows" hiding: stays put
        # until a window actually overlaps it, then steps aside for just
        # that window.
        {
          location = "bottom";
          floating = true;
          # Matches the live panel thickness; the top bar below stays at
          # plasma-manager's 44px default (shrink for a thinner waybar look).
          height = 50;
          lengthMode = "fit";
          hiding = "dodgewindows";
          widgets = [
            {
              iconTasks = {
                # applications:${defaultX.desktopId} rather than
                # preferred://X: we already know exactly which .desktop file
                # each app is, so no reason to route through KDE's runtime
                # `preferred://` resolution and hope it agrees. Stays correct
                # if the underlying feature ever swaps engines.
                #
                # preferred://filemanager is the one holdout: no
                # defaultFileManager feature in this repo to substitute
                # (Dolphin ships with Plasma, not separately chosen here).
                launchers = [
                  "applications:systemsettings.desktop"
                  "applications:${config.defaultTerminal.desktopId}"
                  "preferred://filemanager"
                  "applications:${config.defaultBrowser.desktopId}"
                  "applications:gmail.desktop"
                  "applications:${config.defaultEditor.desktopId}"
                  "applications:google-calendar.desktop"
                ];
              };
            }
          ];
        }

        # Always visible (no `hiding` -- opposite of the dock on purpose).
        # Left: start menu + global app menu. Center: active app name,
        # centered by flanking spacers so it holds regardless of how wide
        # the left/right clusters get. Right: monitoring + tray + clock.
        {
          location = "top";
          floating = true;
          height = 30;
          widgets = [
            # Kickoff = the actual start menu. Appmenu = the Global Menu
            # widget, showing the *focused app's* menu bar inline in the
            # panel instead of inside each window -- classic macOS split.
            "org.kde.plasma.kickoff"
            "org.kde.plasma.appmenu"

            { panelSpacer.expanding = true; }

            # Per-core CPU bar chart. Raw name+config instead of the typed
            # `systemMonitor` widget: that helper always emits plugin
            # "org.kde.plasma.systemmonitor", but this is the dedicated
            # ".cpucore" plasmoid.
            #
            # No per-core SensorColors here on purpose -- KDE auto-generates
            # a rainbow the first time it expands the "cpu/cpu.*/usage"
            # wildcard into real per-core sensors, and regenerates the same
            # one on its own. Hardcoding 32 RGB triples would just be noise.
            {
              name = "org.kde.plasma.systemmonitor.cpucore";
              config = {
                CurrentPreset = "org.kde.plasma.systemmonitor";
                Appearance = {
                  chartFace = "org.kde.ksysguard.barchart";
                  title = "Individual Core Usage";
                };
                Sensors = {
                  highPrioritySensorIds = ''["cpu/cpu.*/usage"]'';
                  totalSensors = ''["cpu/all/usage"]'';
                };
              };
            }

            # Text-shorthand monitoring cluster: CPU temp, Mem, GPU,
            # network down/up. Colors are Catppuccin Mocha accents, avoiding
            # Mauve (system accent, see theme.nix) and Red/Maroon (reserved
            # so red keeps meaning "something's wrong" if threshold coloring
            # ever replaces these static per-metric colors).
            {
              systemMonitor = {
                displayStyle = "org.kde.ksysguard.textonly";
                sensors = [
                  {
                    name = "cpu/all/averageTemperature";
                    color = "247,245,166";
                    label = "CPU";
                  }
                  {
                    name = "memory/physical/usedPercent";
                    color = "166,227,161"; # Catppuccin Mocha Green
                    label = "Mem";
                  }
                  {
                    name = "gpu/all/usage";
                    color = "116,199,236"; # Catppuccin Mocha Sapphire
                    label = "GPU";
                  }
                  {
                    name = "network/all/download";
                    color = "242,205,205"; # Catppuccin Mocha Flamingo
                    label = "↓";
                  }
                  {
                    name = "network/all/upload";
                    color = "137,220,235"; # Catppuccin Mocha Sky
                    label = "↑";
                  }
                ];
              };
            }

            # Clipboard/trash tucked in the popup, always noisy otherwise.
            # Volume/network earn a permanent spot. Camera indicator left
            # out of both lists on purpose -- that's KDE's default "auto"
            # behaviour (shown only when a camera is actually in use).
            {
              systemTray = {
                items = {
                  hidden = [
                    "org.kde.plasma.clipboard"
                    "org.kde.plasma.trash"
                  ];
                  shown = [
                    "org.kde.plasma.volume"
                    "org.kde.plasma.networkmanagement"
                  ];
                };
              };
            }

            "org.kde.plasma.digitalclock"
          ];
        }
      ];
    })
  ];
}
