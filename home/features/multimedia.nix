# home/features/multimedia.nix
{ ... }:
{
  imports = [
    ../modules/mpv.nix
    ../modules/yt-dlp.nix
  ];
}
