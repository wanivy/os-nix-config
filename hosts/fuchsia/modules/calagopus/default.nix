{config, ...}: {
  imports = [
    ./certificates.nix
    ./pterodactyl-migration.nix
  ];

  config = {
    age.secrets = {
      calagopus-panel-key = {
        file = ../../../../secrets/fuchsia/calagopus/app-encryption-key.age;
        owner = "calagopus";
        group = "calagopus";
        mode = "0400";
      };
      calagopus-wings-token-id.file = ../../../../secrets/fuchsia/calagopus/wings-token-id.age;
      calagopus-wings-token.file = ../../../../secrets/fuchsia/calagopus/wings-token.age;
    };
    users.groups = {
      calagopus = {};
      pterodactyl-wings = {};
    };
    users.users = {
      calagopus = {
        isSystemUser = true;
        group = "calagopus";
      };
      pterodactyl-wings = {
        isSystemUser = true;
        group = "pterodactyl-wings";
      };
    };

    services.calagopus = {
      panel = {
        enable = true;
        user = "calagopus";
        group = "calagopus";
        app = {
          url = "https://manage.wanivy.com";
          encryptionKeyFile = config.age.secrets.calagopus-panel-key.path;
        };
        redis.name = "calagopus";
      };

      wings = {
        enable = true;
        user = "pterodactyl-wings";
        group = "pterodactyl-wings";
        rootDir = "/var/lib/pterodactyl-wings";
        logDir = "/var/log/pterodactyl-wings";
        tmpDir = "/var/cache/pterodactyl-wings";
        openFirewall = true;
        secrets = {
          tokenIdFile = config.age.secrets.calagopus-wings-token-id.path;
          tokenFile = config.age.secrets.calagopus-wings-token.path;
        };
        settings = {
          uuid = "e8a75ab3-8292-4250-9939-ccb8915662b9";
          remote = "https://manage.wanivy.com";
          api = {
            upload_limit = 1024;
            ssl = {
              enabled = true;
              cert = "/var/lib/pterodactyl-wings/certificates/node.wanivy.com.crt";
              key = "/var/lib/pterodactyl-wings/certificates/node.wanivy.com.key";
            };
          };
          docker.network = {
            name = "pterodactyl_nw";
            mode = "pterodactyl_nw";
          };
          remote_query.timeout = 600;
        };
      };
    };
  };
}
