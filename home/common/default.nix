{ pkgs, ... }: {

  imports = [
    ./fontconfig.nix
    ./wayland.nix
    ./niri
    ./waybar
    ./ghostty.nix
    ./zsh
    ./neovim
  ];

  home.preferXdgDirectories = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    TERMINAL_EMULATOR = "ghostty";
    JAVA_OPTS = "-Dawt.useSystemAAFontSettings=on -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel";
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    home-manager
    spotify
    jujutsu
    just
  ];

  home.file.".bin" = {
    source = ./bin;
    recursive = true;
    executable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableZshIntegration = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };

  programs.ssh = {
    enable = true;
    controlMaster = "auto";
    addKeysToAgent = "ask";
  };

  home.file.".ssh/authorized_keys".source = builtins.concatStringsSep "\n" [
    (builtins.readFile ../matthias.idaho/keys/id_ed25519.pub)
    (builtins.readFile ../matthias.siona/keys/id_ed25519.pub)
  ];

  programs.git = {
    enable = true;
    extraConfig = {
      color.branch = "auto";
      color.ui = "auto";
      diff.renamelimit = 0;
      push.default = "matching";
      init.defaultBranch = "main";
    };
    aliases = {
      diffc = "diff --cached";
      co = "checkout";
      ci = "commit";
      st = "status -sb";
      br = "branch -a";
      hist = "log --pretty=format:\"%h %ad | %s%d [%an]\" --graph --date=short";
    };
    ignores = [ "*.swo" "*.swp" ];
  };

  programs.zathura.enable = true;

  services.udiskie = {
    enable = true;
    automount = false;
    notify = true;
    settings.program_options.terminal = "\${TERMINAL_EMULATOR} --working-directory";
  };

  services.playerctld.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
  home.stateVersion = "24.11";

}
