{ pkgs, ... }: {

  home.packages = with pkgs; [
    just
    opencode
    timewarrior

    (import ../../packages/print256colors.nix {inherit pkgs;})
    (import ../../packages/coding-agent.nix {inherit pkgs;})
  ];

}
