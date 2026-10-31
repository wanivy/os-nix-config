{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.wanivy.calagopus.pterodactylMigration;
  panelPackage = pkgs.callPackage ../../packages/calagopus-panel {};

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

  panelCommand = pkgs.writeShellScript "calagopus-panel-migration" ''
    export APP_ENCRYPTION_KEY="$(${pkgs.coreutils}/bin/tr -d '\r\n' < ${lib.escapeShellArg config.age.secrets.calagopus-panel-key.path})"
    exec ${lib.getExe panelPackage} "$@"
  '';

  prepareEnvironment = pkgs.writeShellApplication {
    name = "calagopus-prepare-pterodactyl-environment";
    runtimeInputs = with pkgs; [coreutils gnugrep gnused openssl util-linux];
    text = ''
      destination=/run/calagopus-import/pterodactyl.env
      temporary="$(${pkgs.coreutils}/bin/mktemp /run/calagopus-import/.pterodactyl.env.XXXXXX)"
      trap '${pkgs.coreutils}/bin/rm -f "$temporary"' EXIT
      database_password="$(${pkgs.openssl}/bin/openssl rand -hex 24)"

      ${pkgs.util-linux}/bin/runuser --user mysql -- \
        ${config.services.mysql.package}/bin/mariadb --batch <<SQL
      CREATE USER IF NOT EXISTS 'calagopus-import'@'127.0.0.1' IDENTIFIED BY '$database_password';
      ALTER USER 'calagopus-import'@'127.0.0.1' IDENTIFIED BY '$database_password';
      GRANT SELECT ON panel.* TO 'calagopus-import'@'127.0.0.1';
      SQL

      ${pkgs.gnused}/bin/sed \
        -e 's/^DB_HOST=.*/DB_HOST=127.0.0.1/' \
        -e 's/^DB_USERNAME=.*/DB_USERNAME=calagopus-import/' \
        -e "s/^DB_PASSWORD=.*/DB_PASSWORD=$database_password/" \
        ${lib.escapeShellArg cfg.environmentFile} > "$temporary"

      if ! ${pkgs.gnugrep}/bin/grep -q '^DB_HOST=' "$temporary"; then
        printf '%s\n' 'DB_HOST=127.0.0.1' >> "$temporary"
      fi
      if ! ${pkgs.gnugrep}/bin/grep -q '^DB_USERNAME=' "$temporary"; then
        printf '%s\n' 'DB_USERNAME=calagopus-import' >> "$temporary"
      fi
      if ! ${pkgs.gnugrep}/bin/grep -q '^DB_PASSWORD=' "$temporary"; then
        printf 'DB_PASSWORD=%s\n' "$database_password" >> "$temporary"
      fi

      install -m 0400 -o calagopus -g calagopus "$temporary" "$destination"
    '';
  };

  cleanupDatabaseUser = pkgs.writeShellApplication {
    name = "calagopus-cleanup-pterodactyl-database-user";
    runtimeInputs = [pkgs.util-linux];
    text = ''
      printf '%s\n' "DROP USER IF EXISTS 'calagopus-import'@'127.0.0.1';" | \
        ${pkgs.util-linux}/bin/runuser --user mysql -- \
          ${config.services.mysql.package}/bin/mariadb --batch
    '';
  };

  importDryRun = pkgs.writeShellApplication {
    name = "calagopus-import-pterodactyl-dry-run";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      migration_directory=/var/lib/calagopus-panel/migration
      install -d -m 0700 "$migration_directory"
      rm -f "$migration_directory/pterodactyl-dry-run.ok"

      ${panelCommand} import pterodactyl \
        --environment /run/calagopus-import/pterodactyl.env \
        --dry-run \
        --on-invalid=abort \
        --report "$migration_directory/pterodactyl-dry-run.json"

      touch "$migration_directory/pterodactyl-dry-run.ok"
    '';
  };

  importPterodactyl = pkgs.writeShellApplication {
    name = "calagopus-import-pterodactyl";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      migration_directory=/var/lib/calagopus-panel/migration
      test -f "$migration_directory/pterodactyl-dry-run.ok"

      ${panelCommand} import pterodactyl \
        --environment /run/calagopus-import/pterodactyl.env \
        --on-invalid=abort \
        --report "$migration_directory/pterodactyl-import.json" \
        --yes

      touch "$migration_directory/pterodactyl-imported"
    '';
  };
in {
  options.wanivy.calagopus.pterodactylMigration = {
    enable = lib.mkEnableOption "the one-shot Pterodactyl to Calagopus migration tools";
    environmentFile = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/pterodactyl-panel/.env";
      description = "Pterodactyl panel environment file used as the migration source.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.mysql = {
      enable = true;
      package = pkgs.mariadb;
      settings.mysqld = {
        bind-address = "127.0.0.1";
        port = 3306;
        skip-name-resolve = true;
      };
    };

    systemd.services = {
      calagopus-import-pterodactyl-dry-run = {
        description = "Validate a Pterodactyl to Calagopus migration";
        after = ["mysql.service" "postgresql.service" "redis-calagopus.service"];
        requires = ["mysql.service" "postgresql.service" "redis-calagopus.service"];
        environment = panelEnvironment;
        unitConfig.ConditionPathExists = cfg.environmentFile;
        serviceConfig = {
          Type = "oneshot";
          User = "calagopus";
          Group = "calagopus";
          RuntimeDirectory = "calagopus-import";
          StateDirectory = "calagopus-panel";
          ExecStartPre = ["+${lib.getExe prepareEnvironment}"];
          ExecStart = lib.getExe importDryRun;
          ExecStopPost = ["+${lib.getExe cleanupDatabaseUser}"];
        };
      };

      calagopus-import-pterodactyl = {
        description = "Import Pterodactyl data into Calagopus";
        conflicts = ["calagopus-panel.service"];
        after = ["mysql.service" "postgresql.service" "redis-calagopus.service"];
        requires = ["mysql.service" "postgresql.service" "redis-calagopus.service"];
        environment = panelEnvironment;
        unitConfig = {
          ConditionPathExists = "/var/lib/calagopus-panel/migration/pterodactyl-dry-run.ok";
          OnSuccess = "calagopus-panel.service";
        };
        serviceConfig = {
          Type = "oneshot";
          User = "calagopus";
          Group = "calagopus";
          RuntimeDirectory = "calagopus-import";
          StateDirectory = "calagopus-panel";
          ExecStartPre = ["+${lib.getExe prepareEnvironment}"];
          ExecStart = lib.getExe importPterodactyl;
          ExecStopPost = ["+${lib.getExe cleanupDatabaseUser}"];
        };
      };
    };
  };
}
