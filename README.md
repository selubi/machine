# machine

# Usage Guide
## Applying machine settings to a fresh machine
1.  Install a `nix` distribution in your system and enable flakes. The snippet below will install [Determinate Nix](https://docs.determinate.systems/) which have flakes pre-enabled.
    ```bash
    curl -fsSL https://install.determinate.systems/nix | sh -s -- install
    ```
2. Determine which target you want to use, and run below (the example below will use the `selupc` target). This may take a while. 
    ```bash
    nix run github:nix-community/nh -- home switch github:selubi/machine -c selupc
    ```

Thats literally it! The only dependency needed here is `curl`, `sh` and internet access.

# References
Shout out to these resources on helping me build this setup:
- [Evertras/simple-homemanager](https://github.com/Evertras/simple-homemanager) - If you're new to nix and Home Manager, start here.