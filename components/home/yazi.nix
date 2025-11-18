{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = ",";
    # extraPackages = with pkgs; [ exiftool mediainfo ];
  };
}
