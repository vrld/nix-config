{

  services.udiskie = {
    enable = true;
    automount = false;
    notify = true;
    settings.program_options.terminal = "\${TERMINAL_EMULATOR} --working-directory";
  };

}
