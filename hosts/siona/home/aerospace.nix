{

  services.aerospace.enable = true;
  services.aerospace.settings = {
    automatically-unhide-macos-hidden-apps = true;

    gaps = {
      inner.horizontal = 4;
      inner.vertical = 4;
      outer.top = 0;
      outer.right = 0;
      outer.bottom = 0;
      outer.left = 0;
    };

    mode.main.binding = {
      alt-p = "close --quit-if-last-window";

      alt-j = "focus left";
      alt-i = "focus up";
      alt-l = "focus right";
      alt-k = "focus down";

      alt-shift-j = "move left";
      alt-shift-i = "move up";
      alt-shift-l = "move right";
      alt-shift-k = "move down";

      alt-u = "resize smart +50";
      alt-o = "resize smart -50";
      alt-h = "balance-sizes";

      alt-tab = "workspace-back-and-forth";
      alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

      alt-shift-u = "layout tiles horizontal vertical";
      alt-shift-o = "layout accordion horizontal vertical";

      alt-f = "fullscreen --no-outer-gaps";
      alt-shift-f = "macos-native-fullscreen";

      alt-1 = "summon-workspace 1";
      alt-2 = "summon-workspace 2";
      alt-3 = "summon-workspace 3";
      alt-4 = "summon-workspace 4";
      alt-5 = "summon-workspace 5";
      alt-6 = "summon-workspace 6";
      alt-7 = "summon-workspace 7";
      alt-8 = "summon-workspace 8";
      alt-9 = "summon-workspace 9";

      alt-shift-1 = "move-node-to-workspace 1";
      alt-shift-2 = "move-node-to-workspace 2";
      alt-shift-3 = "move-node-to-workspace 3";
      alt-shift-4 = "move-node-to-workspace 4";
      alt-shift-5 = "move-node-to-workspace 5";
      alt-shift-6 = "move-node-to-workspace 6";
      alt-shift-7 = "move-node-to-workspace 7";
      alt-shift-8 = "move-node-to-workspace 8";
      alt-shift-9 = "move-node-to-workspace 9";

      alt-a = "mode aero";
    };

    mode.aero.binding = {
      alt-a = "mode main";

      p = [ "close --quit-if-last-window"  "mode main" ];

      j = [ "focus left" "mode main" ];
      i = [ "focus up" "mode main" ];
      l = [ "focus right" "mode main" ];
      k = [ "focus down" "mode main" ];

      alt-j = "move left";
      alt-i = "move up";
      alt-l = "move right";
      alt-k = "move down";

      shift-j = [ "join-with left" "mode main" ];
      shift-i = [ "join-with up" "mode main" ];
      shift-l = [ "join-with right" "mode main" ];
      shift-k = [ "join-with down" "mode main" ];

      u = "resize smart +50";
      o = "resize smart -50";
      h = [ "balance-sizes" "mode main" ];
      f = [ "fullscreen --no-outer-gaps" "mode main" ];

      tab = [ "workspace-back-and-forth" "mode main" ];
      shift-tab = [ "move-workspace-to-monitor --wrap-around next" "mode main" ];

      shift-u = [ "layout tiles horizontal vertical" "mode main" ];
      shift-o = [ "layout accordion horizontal vertical" "mode main" ];

      "1" = [ "summon-workspace 1" "mode main"];
      "2" = [ "summon-workspace 2" "mode main"];
      "3" = [ "summon-workspace 3" "mode main"];
      "4" = [ "summon-workspace 4" "mode main"];
      "5" = [ "summon-workspace 5" "mode main"];
      "6" = [ "summon-workspace 6" "mode main"];
      "7" = [ "summon-workspace 7" "mode main"];
      "8" = [ "summon-workspace 8" "mode main"];
      "9" = [ "summon-workspace 9" "mode main"];

      shift-1 = [ "move-node-to-workspace 1" "mode main" ];
      shift-2 = [ "move-node-to-workspace 2" "mode main" ];
      shift-3 = [ "move-node-to-workspace 3" "mode main" ];
      shift-4 = [ "move-node-to-workspace 4" "mode main" ];
      shift-5 = [ "move-node-to-workspace 5" "mode main" ];
      shift-6 = [ "move-node-to-workspace 6" "mode main" ];
      shift-7 = [ "move-node-to-workspace 7" "mode main" ];
      shift-8 = [ "move-node-to-workspace 8" "mode main" ];
      shift-9 = [ "move-node-to-workspace 9" "mode main" ];
    };
  };

}
