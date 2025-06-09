{

  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "15m";

    jails.postfix.settings = {
      filter = "postfix";
      maxretry = 3;
      action = ''iptables[name=postfix, port="smtp,submissions", protocol=tcp]'';
    };

    jails.dovecot.settings = {
      filter = "dovecot";
      maxretry = 3;
      action = ''iptables[name=dovecot, port="imap,imaps", protocol=tcp]'';
    };

    jails.postfix-ddos.settings = {
      filter = "postfix-ddos";
      maxretry = 3;
      action = ''iptables[name=postfix, port="smtp,submission", protocol=tcp]'';
      bantime = "2h";
    };
  };

  environment.etc."fail2ban/filter.d/postfix-ddos.conf".text = ''
    [Definition]
    failregex = lost connection after EHLO from \S+\[<HOST>\]
  '';

}
