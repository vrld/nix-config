{ pkgs, lib, ... }: {

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
    } // lib.optionalAttrs pkgs.stdenv.isLinux {
      zsh-autoenv.enable = true;
      vteIntegration = true;
    };
  };

}
