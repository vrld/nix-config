{

  programs.ssh = {
    enable = true;
    controlMaster = "auto";
    addKeysToAgent = "ask";
  };

}
