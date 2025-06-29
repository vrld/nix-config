{
  inputs,
  pkgs,
  outputs,
  color-scheme,
  ...
}: let
  pkgs-stable = import inputs.nixpkgs-stable {
    inherit (pkgs.stdenv.hostPlatform) system;
  };
  user = "matthias";
in {

  imports = [
    inputs.home-manager.darwinModules.home-manager
    ./aerospace.nix
    ./homebrew.nix
  ];

  system.primaryUser = user;
  users.users.${user} = {
    shell = pkgs.zsh;
    home = /Users/${user};
    packages = [
      (pkgs.writeShellScriptBin "is-in-light-mode" "! defaults read -g AppleInterfaceStyle >/dev/null 2>&1")
      # see https://brettterpstra.com/2018/09/26/shell-tricks-toggling-dark-mode-from-terminal/
      (pkgs.writeShellScriptBin "change-colors" ''
        osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to not dark mode'
      '')
    ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${user} = import ./${user}.nix;
    extraSpecialArgs = { inherit inputs outputs color-scheme pkgs-stable user; };
  };

  nix-homebrew = { inherit user; };

}
