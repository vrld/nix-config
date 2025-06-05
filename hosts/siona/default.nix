{
  pkgs,
  ...
}: {
  imports = [
    ../../components/fonts.nix
    ../../components/zsh.nix
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
        tilesize = 32;
        autohide = false;
        appswitcher-all-displays = true;
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = false;
        _FXShowPosixPathInTitle = true;
      };

      loginwindow.GuestEnabled = false;
      loginwindow.autoLoginUser = "matthias";

      spaces.spans-displays = false;

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
    zsh.enableFastSyntaxHighlighting = true;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 6;

}
