{
  config,
  lib,
  pkgs,
  ...
}: let
  wings = config.services.pterodactyl.wings;
  domain = "node.wanivy.com";
  caddyCertificateDir = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${domain}";
  certificate = "${caddyCertificateDir}/${domain}.crt";
  privateKey = "${caddyCertificateDir}/${domain}.key";
  destinationDir = "${wings.rootDir}/certificates";

  installCertificates = pkgs.writeShellApplication {
    name = "pterodactyl-wings-certificates";
    runtimeInputs = with pkgs; [coreutils];
    text = ''
      for _attempt in $(${pkgs.coreutils}/bin/seq 1 60); do
        if [[ -s ${lib.escapeShellArg certificate} && -s ${lib.escapeShellArg privateKey} ]]; then
          install -d -m 0700 -o ${wings.user} -g ${wings.group} ${lib.escapeShellArg destinationDir}
          install -m 0600 -o ${wings.user} -g ${wings.group} \
            ${lib.escapeShellArg certificate} ${lib.escapeShellArg "${destinationDir}/${domain}.crt"}
          install -m 0600 -o ${wings.user} -g ${wings.group} \
            ${lib.escapeShellArg privateKey} ${lib.escapeShellArg "${destinationDir}/${domain}.key"}
          exit 0
        fi
        sleep 2
      done

      echo "Caddy certificate for ${domain} is not available" >&2
      exit 1
    '';
  };
in {
  config = lib.mkIf wings.enable {
    systemd = {
      services = {
        pterodactyl-wings = {
          after = ["pterodactyl-wings-cert-install.service"];
          requires = ["pterodactyl-wings-cert-install.service"];
        };

        pterodactyl-wings-cert-install = {
          description = "Install Caddy certificate for Pterodactyl Wings";
          after = ["caddy.service"];
          requires = ["caddy.service"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = lib.getExe installCertificates;
          };
        };

        pterodactyl-wings-cert-sync = {
          description = "Synchronize renewed Pterodactyl Wings certificate";
          serviceConfig = {
            Type = "oneshot";
            ExecStart = lib.getExe installCertificates;
            ExecStartPost = "${pkgs.systemd}/bin/systemctl --no-block try-restart pterodactyl-wings.service";
          };
        };
      };

      paths.pterodactyl-wings-cert-sync = {
        wantedBy = ["multi-user.target"];
        pathConfig = {
          PathModified = certificate;
          Unit = "pterodactyl-wings-cert-sync.service";
        };
      };
    };
  };
}
