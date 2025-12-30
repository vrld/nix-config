{ pkgs, ... }:
let
  username = "matthias";
  homeDirectory = "/home/${username}";
in
{
  imports = [
    ../../components/home/bat.nix
    ../../components/home/sqlite.nix
    ../../components/home/ssh.nix
    ../../components/home/vcs.nix

    ../../components/home/neovim
    ../../components/home/neovim/mini.nix
  ];

  home = {
    inherit username homeDirectory;
    preferXdgDirectories = true;
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "Matthias Richter";
      email = "vrld@vrld.org";
    };
  };
  home.packages = with pkgs; [ just jujutsu /* and */ zola ];

  systemd.user.startServices = "sd-switch";

}
