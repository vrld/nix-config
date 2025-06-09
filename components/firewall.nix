{

  networking.firewall = {
    enable = true;

    # rate limit SSH connections
    extraCommands = ''
      iptables -I INPUT -p tcp --dport 22 -i eth0 -m state --state NEW -m recent --set
      iptables -I INPUT -p tcp --dport 22 -i eth0 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
    '';
  };

}
