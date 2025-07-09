{pkgs, lib, ...}: {

  environment.systemPackages = with pkgs; [
    btop   # processes
    iftop  # network

    dnsutils
    file
    gnupg
    lsof
    screen
    zellij
    wget
    which

    bc
    gawk
    gnumake
    gnused

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
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    iotop  # disk
    ltrace  # trace library calls
    strace  # trace syscalls
  ];

}
