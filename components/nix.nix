{

  programs.nh.enable = true;

  nix = {
    enable = true;

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      download-buffer-size = 128 * 1024 * 1024; # 128 MiB
    };

    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
      options = "--delete-older-than +3";
    };
  };


}
