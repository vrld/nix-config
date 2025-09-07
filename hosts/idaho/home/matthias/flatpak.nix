{ inputs, config, ... }:
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
    packages = [
      "br.com.wiselabs.simplexity"
    ];
  };

}
