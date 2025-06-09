{pkgs, ...}: {

  environment.systemPackages = with pkgs; [
    btop   # processes
    iftop  # network
    iotop  # disk

    dnsutils
    file
    gnupg
    lsof
    screen
    wget
    which

    bc
    gawk
    gnumake
    gnused
    ltrace
    strace

    gnutar
    p7zip
    unzip
    xz
    zip
    zstd

    eza
    fd
    fzf
    jq
    ripgrep
  ];

  programs = {
    mosh.enable = true;
  };

}
