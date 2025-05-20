{
  pkgs,
  ...
}: {
  imports = [
    ../common/fonts.nix
    #./sops.nix
    ./home
  ];

  nix.enable = false;

  system = {
    # checks.verifyNixPath = false;
    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyleSwitchesAutomatically = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        "com.apple.swipescrolldirection" = false;  # nothing natural about "Natural" scrolling
      };

      # firewall handled by MDM

      dock = {
        enable-spring-load-actions-on-all-items = true;
        tilesize = 48;
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = false;
        _FXShowPosixPathInTitle = true;
      };

      loginwindow.GuestEnabled = false;

      trackpad.Clicking = true;
    };

    keyboard = {
      enableKeyMapping = true;
    };
  };

  networking = {
    computerName = "Siona";
    hostName = "siona";
    localHostName = "siona";
  };

  environment.shells = [ pkgs.zsh ];

  environment.systemPackages = with pkgs; [
    mosh
    screen
    file
    gawk
    gnumake
    gnupg
    gnused
    gnutar
    p7zip
    unzip
    xz
    zip
    zstd
    eza
    fd
    fzf
    jq
    ripgrep
    wget
  ];

  programs = {
    nix-index.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      enableFastSyntaxHighlighting = true;
    };

  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 6;

}
