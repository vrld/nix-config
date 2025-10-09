{
  pkgs,
  ...
}: {
  imports = [
    ../../components/fonts.nix
    ../../components/packages.nix
    ../../components/zsh.nix
    ./home
  ];

  nix.enable = false;

  system = {
    # checks.verifyNixPath = false;
    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleInterfaceStyleSwitchesAutomatically = false;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        "com.apple.swipescrolldirection" = false;  # nothing natural about "Natural" scrolling
      };

      # firewall handled by MDM

      dock = {
        enable-spring-load-actions-on-all-items = true;
        tilesize = 48;
        autohide = true;
        appswitcher-all-displays = false;
        expose-group-apps = true;
        orientation = "left";
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

  programs = {
    nix-index.enable = true;
    zsh.enableFastSyntaxHighlighting = true;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 6;

}
