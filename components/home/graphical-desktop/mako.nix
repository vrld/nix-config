{

  services.mako = {
    enable = true;

    settings = {
      default-timeout = 5000;

      border-size = 4;
      border-radius = 8;
      padding = "12";

      font = "Hack Nerd Font";
      background-color = "#000000DF";
      text-color = "#EBDBB2FF";
      border-color = "#0766788F";
      progress-color = "over #C87F79FF";
    };

    settings."urgency=critical" = {
      border-color = "#CC241DFF";
      background-color = "#EBDBB2";
      text-color = "#202020";
      default-timeout = 0;
    };
  };

}
