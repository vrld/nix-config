{ pkgs, ... }:
{
  programs.ssh =
    if pkgs.lib.strings.hasPrefix "25.05" pkgs.lib.version then
      {
        enable = true;
        controlMaster = "auto";
        addKeysToAgent = "auto";
      }
    else
      {
        enable = true;
        enableDefaultConfig = false;
        matchBlocks."*" = {
          forwardAgent = false;
          addKeysToAgent = "ask";
          controlMaster = "auto"; # opportunistic multiplexing: try to use existing connection, fall back to creating a new one
          controlPath = "~/.ssh/%C.control";
          controlPersist = "no";
          compression = false;
          serverAliveInterval = 0;
          serverAliveCountMax = 3;
          hashKnownHosts = false;
          userKnownHostsFile = "~/.ssh/known_hosts";
        };

      };
}
