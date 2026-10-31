{...}: {
  networking.useDHCP = false;
  networking.useNetworkd = true;
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  networking.extraHosts = ''
    144.31.203.21 fuchsia.wanivy.com fuchsia
    2001:470:1f15:658::1 fuchsia.wanivy.com fuchsia
  '';

  systemd.network = {
    enable = true;

    netdevs."20-he-ipv6" = {
      netdevConfig = {
        Name = "he-ipv6";
        Kind = "sit";
        MTUBytes = 1280;
      };
      tunnelConfig = {
        Local = "144.31.203.21";
        Remote = "216.66.84.46";
        TTL = 255;
      };
    };

    networks = {
      "10-ens3" = {
        matchConfig.Name = "ens3";
        address = ["144.31.203.21/32"];
        routes = [
          {
            Gateway = "10.0.0.1";
            GatewayOnLink = true;
          }
        ];
        tunnel = ["he-ipv6"];
        networkConfig.IPv6AcceptRA = false;
        linkConfig.RequiredForOnline = "routable";
      };

      "20-he-ipv6" = {
        matchConfig.Name = "he-ipv6";
        address = [
          "2001:470:1f14:65a::2/64"
          "2001:470:1f15:658::1/128"
        ];
        routes = [
          {
            Destination = "::/0";
            Gateway = "2001:470:1f14:65a::1";
            PreferredSource = "2001:470:1f15:658::1";
          }
        ];
        networkConfig.ConfigureWithoutCarrier = true;
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };

  services.caddy.enable = true;

  systemd.services.caddy.serviceConfig = {
    AmbientCapabilities = ["CAP_NET_BIND_SERVICE"];
    CapabilityBoundingSet = ["CAP_NET_BIND_SERVICE"];
  };

  networking.firewall = {
    enable = true;
    interfaces.pterodactyl0.allowedTCPPorts = [
      3306
      5432
    ];
    allowedTCPPorts = [
      80
      443
    ];
    allowedTCPPortRanges = [
      {
        from = 25565;
        to = 25600;
      }
    ];
    allowedUDPPorts = [443];
    allowedUDPPortRanges = [
      {
        from = 25565;
        to = 25600;
      }
    ];
    extraInputRules = ''
      ip saddr 216.66.84.46 ip protocol 41 accept
    '';
  };
}
