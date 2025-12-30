{ pkgs, ... }:
let
  username = "matthias";
  homeDirectory = "/home/${username}";
in
{
  imports = [
    ../../../../components/home/bat.nix
    ../../../../components/home/graphical-desktop/ghostty.nix
    ../../../../components/home/graphical-desktop/foot.nix
    ../../../../components/home/gpg.nix
    ../../../../components/home/packages.nix
    ../../../../components/home/password-store.nix
    ../../../../components/home/sqlite.nix
    ../../../../components/home/ssh.nix
    ../../../../components/home/vcs.nix
    ../../../../components/home/yazi.nix
    ../../../../components/home/zsh

    ../../../../components/home/graphical-desktop/niri

    ../../../../components/home/neovim
    ../../../../components/home/neovim/copilot.nix
    ../../../../components/home/neovim/lsp.nix
    ../../../../components/home/neovim/markdown.nix
    ../../../../components/home/neovim/mini.nix
    ../../../../components/home/neovim/treesitter.nix
    ../../../../components/home/neovim/vcs.nix

    ./calendar.nix
    ./contacts.nix
    ./email.nix
    ./firefox.nix
    ./sops.nix
    ./waybar.nix

    ./flatpak.nix
  ];

  home = {
    inherit username homeDirectory;
    preferXdgDirectories = true;

    sessionVariables = {
      JAVA_OPTS = "-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel";
      LEDGER_FILE = "${homeDirectory}/Themen/Finanzen/journal/personal/all.journal";
    };

    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    hledger
    when

    (imagemagick.override {
      libX11Support = false;
      libXtSupport = false;
    })

    platformio-core
    esptool
    python313Packages.uv
    python313Packages.ipython

    zola

    artisan
    obsidian
    signal-desktop
    spotify

    orca-slicer

    # chaotic nyx
    discord-krisp
  ];

  #services.yubikey-agent.enable = true;

  programs.git.settings.user = {
    name = "Matthias Richter";
    email = "vrld@vrld.org";
  };

  services.nextcloud-client.enable = true;
  services.syncthing.enable = true;
  services.syncthing.tray.enable = true;

  home.file.".when/preferences".text = ''
    calendar = ${homeDirectory}/.when/calendar
    editor = nvim
    past = 0
    header = 0
    wrap_auto = 0
    monday_first = y
    language = de
    ampm = 0
  '';

  home.file.".ssh/id_ecdsa.pub".source = ./keys/id_ecdsa.pub;
  home.file.".ssh/id_ed25519.pub".source = ./keys/id_ed25519.pub;

  services.kanshi.settings = [
    {
      profile.name = "undocked";
      profile.outputs = [
        {
          criteria = "AU Optronics 0x226D Unknown";
          mode = "1920x1080";
          position = "3440,360";
        }
      ];
    }

    {
      profile.name = "docked";
      profile.outputs = [
        {
          criteria = "LG Electronics LG ULTRAWIDE 0x00055D56";
          mode = "3440x1440";
          position = "0,0";
        }
        {
          criteria = "AU Optronics 0x226D Unknown";
          mode = "1920x1080";
          position = "3440,360";
        }
      ];
    }
  ];

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  systemd.user.startServices = "sd-switch";

}
