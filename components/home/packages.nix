{ pkgs, ... }: {

  home.packages = with pkgs; [
    just
    opencode
    timewarrior

    (import ../../packages/print256colors.nix {inherit pkgs;})
  ];

}
