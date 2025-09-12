{ inputs, config, pkgs, ... }:
let
  # add flatpaks here
  flatpaks = {
    simplexity = "br.com.wiselabs.simplexity";
    televido = "de.k_bo.Televido";
  };

  # massage flatpaks into array of packages and list of urls
  names = builtins.attrNames flatpaks;
  urls = builtins.map (name: flatpaks."${name}") names;
  packages = builtins.map (name: pkgs.writeShellScriptBin name ''flatpak run ${flatpaks."${name}"} "$@"'') names;
in
{

  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  xdg.systemDirs.data = [
    "/var/lib/flatpak/exports/share"
    "${config.home.homeDirectory}/.local/share/flatpak/exports/share"
  ];

  services.flatpak = {
    enable = true;
    update.onActivation = true;
    uninstallUnmanaged = true;
    packages = urls;
  };

  home.packages = packages;

}
