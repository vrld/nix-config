{
  pkgs,
  ...
}:
{
  # TODO
  programs.firefox = {
    enable = true;
    languagePacks = [ "de" "en-US" ];
    profiles.default = {
      id = 0;  # implies isDefault = true
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        cookie-autodelete
        sponsorblock
        multi-account-containers
        user-agent-string-switcher
        stylus
        untrap-for-youtube
        old-reddit-redirect
        reddit-enhancement-suite
        keepa
        imagus
      ];

      settings = {
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "uBlock0@raymondhill.net".settings = {
          selectedFilterLists = [
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-unbreak"
            "ublock-quick-fixes"
          ];
        };
      };

      containers = {
        EB = {
          color = "green";
          icon = "fence";
          id = 1;
        };
        Arbeit = {
          color = "blue";
          icon = "briefcase";
          id = 2;
        };
      };
    };
  };

}
