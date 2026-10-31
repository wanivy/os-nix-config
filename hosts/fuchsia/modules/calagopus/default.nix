{
  config,
  lib,
  pkgs,
  ...
}: let
  panelPackage = pkgs.calagopus-panel;
  wingsPackage = pkgs.calagopus-wings;
  yaml = pkgs.formats.yaml {};

  panelEnvironment = {
    APP_DEBUG = "false";
    APP_PRIMARY = "true";
    APP_URL = "https://manage.wanivy.com";
    BIND = "127.0.0.1";
    DATABASE_MIGRATE = "true";
    DATABASE_URL = "postgresql://calagopus@localhost/calagopus?host=/run/postgresql";
    PORT = "8000";
    REDIS_KEY_PREFIX = "calagopus";
    REDIS_MODE = "redis";
    REDIS_URL = "redis://127.0.0.1:6380/0";
  };

  panelCommand = pkgs.writeShellScript "calagopus-panel-start" ''
    export APP_ENCRYPTION_KEY="$(${pkgs.coreutils}/bin/tr -d '\r\n' < ${lib.escapeShellArg config.age.secrets.calagopus-panel-key.path})"
    exec ${lib.getExe panelPackage} "$@"
  '';

  wingsConfig = yaml.generate "calagopus-wings.yml" {
    uuid = "e8a75ab3-8292-4250-9939-ccb8915662b9";
    remote = "https://manage.wanivy.com";
    api = {
      host = "0.0.0.0";
      port = 8080;
      upload_limit = 1024;
      ssl = {
        enabled = true;
        cert = "/var/lib/pterodactyl-wings/certificates/node.wanivy.com.crt";
        key = "/var/lib/pterodactyl-wings/certificates/node.wanivy.com.key";
      };
    };
    system = {
      root_directory = "/var/lib/pterodactyl-wings";
      log_directory = "/var/log/pterodactyl-wings";
      data = "/var/lib/pterodactyl-wings/volumes";
      archive_directory = "/var/lib/pterodactyl-wings/archives";
      backup_directory = "/var/lib/pterodactyl-wings/backups";
      tmp_directory = "/var/cache/pterodactyl-wings";
      username = "pterodactyl-wings";
      sftp.bind_port = 2022;
    };
    docker.network = {
      name = "pterodactyl_nw";
      mode = "pterodactyl_nw";
    };
    remote_query.timeout = 600;
    ignore_panel_config_updates = true;
    ignore_panel_wings_upgrades = true;
  };

  wingsCommand = pkgs.writeShellScript "calagopus-wings-start" ''
    export CALAGOPUS_TOKEN_ID="$(${pkgs.coreutils}/bin/tr -d '\r\n' < ${lib.escapeShellArg config.age.secrets.calagopus-wings-token-id.path})"
    export CALAGOPUS_TOKEN="$(${pkgs.coreutils}/bin/tr -d '\r\n' < ${lib.escapeShellArg config.age.secrets.calagopus-wings-token.path})"
    exec ${lib.getExe wingsPackage} --config /run/calagopus-wings/config.yml --no-setup
  '';

  domain = "node.wanivy.com";
  caddyCertificateDir = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${domain}";
  installWingsCertificates = pkgs.writeShellApplication {
    name = "calagopus-wings-certificates";
    runtimeInputs = with pkgs; [coreutils];
    text = ''
      for _attempt in $(${pkgs.coreutils}/bin/seq 1 60); do
        if [[ -s ${lib.escapeShellArg "${caddyCertificateDir}/${domain}.crt"} && -s ${lib.escapeShellArg "${caddyCertificateDir}/${domain}.key"} ]]; then
          install -d -m 0700 -o pterodactyl-wings -g pterodactyl-wings /var/lib/pterodactyl-wings/certificates
          install -m 0600 -o pterodactyl-wings -g pterodactyl-wings \
            ${lib.escapeShellArg "${caddyCertificateDir}/${domain}.crt"} /var/lib/pterodactyl-wings/certificates/${domain}.crt
          install -m 0600 -o pterodactyl-wings -g pterodactyl-wings \
            ${lib.escapeShellArg "${caddyCertificateDir}/${domain}.key"} /var/lib/pterodactyl-wings/certificates/${domain}.key
          exit 0
        fi
        sleep 2
      done

      echo "Caddy certificate for ${domain} is not available" >&2
      exit 1
    '';
  };
in {
  imports = [./pterodactyl-migration.nix];

  config = {
    age.secrets = {
      calagopus-panel-key = {
        file = ../../../../secrets/fuchsia/calagopus/app-encryption-key.age;
        owner = "calagopus";
        group = "calagopus";
        mode = "0400";
      };
      calagopus-wings-token-id.file = ../../../../secrets/fuchsia/pterodactyl/wings-token-id.age;
      calagopus-wings-token.file = ../../../../secrets/fuchsia/pterodactyl/wings-token.age;
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
    environment.systemPackages = [panelPackage wingsPackage];

    services.postgresql = {
      enable = true;
      ensureDatabases = ["calagopus"];
      ensureUsers = [
        {
          name = "calagopus";
          ensureDBOwnership = true;
        }
      ];
    };

    services.redis.servers.calagopus = {
      enable = true;
      bind = "127.0.0.1";
      port = 6380;
    };

    virtualisation.docker.enable = true;

    systemd = {
      tmpfiles.rules = [
        "d /var/lib/pterodactyl-wings 0700 pterodactyl-wings pterodactyl-wings - -"
        "d /var/log/pterodactyl-wings 0700 pterodactyl-wings pterodactyl-wings - -"
        "d /var/cache/pterodactyl-wings 0700 pterodactyl-wings pterodactyl-wings - -"
      ];

      services = {
        calagopus-panel = {
          description = "Calagopus Panel";
          wantedBy = ["multi-user.target"];
          wants = ["network-online.target"];
          after = ["network-online.target" "postgresql.service" "redis-calagopus.service"];
          requires = ["postgresql.service" "redis-calagopus.service"];
          environment = panelEnvironment;
          serviceConfig = {
            User = "calagopus";
            Group = "calagopus";
            ExecStart = panelCommand;
            Restart = "on-failure";
            RestartSec = "5s";
            StateDirectory = "calagopus-panel";
            WorkingDirectory = "/var/lib/calagopus-panel";
            PrivateTmp = true;
            NoNewPrivileges = true;
            ProtectHome = true;
            ProtectSystem = "strict";
            ReadWritePaths = ["/var/lib/calagopus-panel"];
          };
        };

        calagopus-wings = {
          description = "Calagopus Wings";
          wantedBy = ["multi-user.target"];
          wants = ["network-online.target"];
          after = ["docker.service" "network-online.target" "calagopus-wings-cert-install.service"];
          requires = ["docker.service" "calagopus-wings-cert-install.service"];
          serviceConfig = {
            ExecStartPre = "${pkgs.coreutils}/bin/install -Dm600 ${wingsConfig} /run/calagopus-wings/config.yml";
            ExecStart = wingsCommand;
            Restart = "on-failure";
            RestartSec = "5s";
            RuntimeDirectory = "calagopus-wings";
            LimitNOFILE = 4096;
          };
        };

        calagopus-wings-cert-install = {
          description = "Install Caddy certificate for Calagopus Wings";
          after = ["caddy.service"];
          requires = ["caddy.service"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = lib.getExe installWingsCertificates;
          };
        };

        calagopus-wings-cert-sync = {
          description = "Synchronize renewed Calagopus Wings certificate";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = lib.getExe installWingsCertificates;
            ExecStartPost = "${pkgs.systemd}/bin/systemctl --no-block try-restart calagopus-wings.service";
          };
        };
      };

      paths.calagopus-wings-cert-sync = {
        wantedBy = ["multi-user.target"];
        pathConfig = {
          PathModified = "${caddyCertificateDir}/${domain}.crt";
          Unit = "calagopus-wings-cert-sync.service";
        };
      };
    };
  };
}
