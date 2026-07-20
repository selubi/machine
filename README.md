# machine

# Usage Guide
## Applying machine settings to a fresh machine
1.  Install a `nix` distribution in your system and enable flakes. The snippet below will install [Determinate Nix](https://docs.determinate.systems/) which have flakes pre-enabled.
    ```bash
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install
    ```
2. Determine which target you want to use, and run below (the example below will use the `selubi@selupc` target). This may take a while. 
    ```bash
    nix run github:nix-community/home-manager -- switch --flake github:selubi/machine#selubi@selupc
    ```

Thats literally it! The only dependency needed here is `curl`, `sh` and internet access.


## Available targets
The available targets are formatted as `userName@machineName`, where `machineName` matches the attribute keys defined under `globalConfig.machines`, and `userName` matches attribute keys of `globalConfig.machines.users`.

Here is an example. If the globalConfig looks like this:
```nix
{
  machines = {
    selupc = {
      system = "x86_64-linux";
      users.selubi.homeConfiguration = [ ... ];
      users.guest.homeConfiguration = [ ... ];
    };
    selumacbook = {
      system = "aarch64-darwin";
      users.selubi.homeConfiguration = [ ... ];
    };
  };
}
```

Then:
```
selubi@selupc
guest@selupc
selubi@selumacbook
```
are all valid targets.

# References
Shout out to these resources on helping me build this setup:
- [Evertras/simple-homemanager](https://github.com/Evertras/simple-homemanager) - If you're new to nix and Home Manager, start here.