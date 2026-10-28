{config, ...}: let
  domain = "node.wanivy.com";
in {
  imports = [./certificates.nix];

  age.secrets = {
    pterodactyl-wings-token-id = {
      file = ../../../../../secrets/fuchsia/pterodactyl/wings-token-id.age;
      mode = "0400";
    };
    pterodactyl-wings-token = {
      file = ../../../../../secrets/fuchsia/pterodactyl/wings-token.age;
      mode = "0400";
    };
  };

  services.pterodactyl.wings = {
    enable = true;
    openFirewall = true;
    rootDir = "/var/lib/pterodactyl-wings";
    logDir = "/var/log/pterodactyl-wings";
    tmpDir = "/var/cache/pterodactyl-wings";
    runDir = "/run/pterodactyl-wings";

    secrets = {
      tokenIdFile = config.age.secrets.pterodactyl-wings-token-id.path;
      tokenFile = config.age.secrets.pterodactyl-wings-token.path;
    };

    settings = {
      uuid = "e8a75ab3-8292-4250-9939-ccb8915662b9";
      remote = "https://manage.wanivy.com";
      api = {
        port = 8080;
        upload_limit = 1024;
        ssl = {
          enabled = true;
          cert = "/var/lib/pterodactyl-wings/certificates/${domain}.crt";
          key = "/var/lib/pterodactyl-wings/certificates/${domain}.key";
        };
      };
      system.sftp.bind_port = 2022;
      remote_query.timeout = 600;
    };
  };
}
