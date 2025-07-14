{
  hardware.printers.ensurePrinters = [
    {
      name = "Lexmark_B2338dw";
      description = "Lexmark B2338dw";
      location = "home";
      deviceUri = "dnssd://Lexmark%20B2338dw._ipp._tcp.local/?uuid=de0d7aae-f6f1-427b-b41d-bc467f8246b2";
      model = "everywhere";
      ppdOptions = {
        PageSize = "A4";
        Duplex =  "DuplexNoTumble";
      };
    }
  ];

  hardware.printers.ensureDefaultPrinter = "Lexmark_B2338dw";
}
