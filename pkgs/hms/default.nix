{ writeShellApplication, dix, nix, mktemp, bash }:

writeShellApplication {
  name = "hms"; # This becomes the runnable command name in your terminal

  # Nix ensures these tools are bundled inside this script's private path
  runtimeInputs = [ 
    bash 
    dix 
    nix 
    mktemp
  ];

  # This reads your local bash file from the same directory
  text = builtins.readFile ./hms.sh; 
}