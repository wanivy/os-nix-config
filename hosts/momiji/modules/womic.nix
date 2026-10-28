{pkgs, ...}: {
  environment.systemPackages = [
    (pkgs.callPackage ../packages/womic {})
    pkgs.alsa-utils
  ];

  boot = {
    kernelModules = ["snd-aloop"];
    extraModprobeConfig = ''
      options snd-aloop id=Loopback pcm_substreams=2
    '';
  };

  networking.firewall.allowedUDPPorts = [49152];

  services.pipewire = {
    extraConfig.pipewire."20-womic" = {
      "context.objects" = [
        {
          factory = "adapter";
          flags = ["nofail"];
          args = {
            "factory.name" = "api.alsa.pcm.source";
            "node.name" = "womic";
            "node.description" = "WO Mic";
            "media.class" = "Audio/Source";
            "api.alsa.path" = "hw:Loopback,1,0";
            "audio.format" = "S16LE";
            "audio.rate" = 48000;
            "audio.channels" = 1;
            "audio.position" = ["MONO"];
            "node.pause-on-idle" = false;
            "session.suspend-timeout-seconds" = 0;
            "priority.session" = 100;
          };
        }
      ];
    };

    wireplumber.extraConfig."51-womic" = {
      "monitor.alsa.rules" = [
        {
          matches = [{"device.name" = "alsa_card.platform-snd_aloop.0";}];
          actions.update-props."device.disabled" = true;
        }
      ];
    };
  };
}
