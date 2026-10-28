{
  config,
  pkgs,
  ...
}: {
  age.secrets = {
    pterodactyl-panel-key = {
      file = ../../../../../secrets/fuchsia/pterodactyl/app-key.age;
      owner = "caddy";
      group = "caddy";
      mode = "0400";
    };

    pterodactyl-panel-hashids-salt = {
      file = ../../../../../secrets/fuchsia/pterodactyl/hashids-salt.age;
      owner = "caddy";
      group = "caddy";
      mode = "0400";
    };
  };

  services.pterodactyl.panel = {
    enable = true;
    enableNginx = false;
    user = "caddy";
    group = "caddy";

    app = {
      name = "fuchsia";
      env = "production";
      debug = false;
      keyFile = config.age.secrets.pterodactyl-panel-key.path;
      timezone = "Europe/Moscow";
      url = "https://manage.wanivy.com";
      environmentOnly = false;
    };

    database = {
      createLocally = true;
      name = "panel";
      user = "caddy";
    };

    redis = {
      createLocally = true;
      name = "pterodactyl-panel";
    };

    hashids = {
      saltFile = config.age.secrets.pterodactyl-panel-hashids-salt.path;
      length = 8;
    };

    recaptcha.enabled = false;
    telemetry.enable = false;
  };

  services.caddy.package = pkgs.frankenphp.override {
    php = config.services.pterodactyl.panel.phpPackage;
  };

  systemd.services.caddy = {
    after = ["pterodactyl-panel-setup.service"];
    requires = ["pterodactyl-panel-setup.service"];
  };
}
