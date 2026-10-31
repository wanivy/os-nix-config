{
  lib,
  pkgs,
  ...
}: let
  domain = "node.wanivy.com";
  wingsCertificateDir = "/var/lib/pterodactyl-wings/certificates";
  caddyCertificateDir = "/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/${domain}";

  installWingsCertificates = pkgs.writeShellApplication {
    name = "calagopus-wings-certificates";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      for _attempt in $(${pkgs.coreutils}/bin/seq 1 60); do
        if [[ -s ${lib.escapeShellArg "${caddyCertificateDir}/${domain}.crt"} && -s ${lib.escapeShellArg "${caddyCertificateDir}/${domain}.key"} ]]; then
          install -d -m 0700 -o pterodactyl-wings -g pterodactyl-wings ${lib.escapeShellArg wingsCertificateDir}
          install -m 0600 -o pterodactyl-wings -g pterodactyl-wings \
            ${lib.escapeShellArg "${caddyCertificateDir}/${domain}.crt"} \
            ${lib.escapeShellArg "${wingsCertificateDir}/${domain}.crt"}
          install -m 0600 -o pterodactyl-wings -g pterodactyl-wings \
            ${lib.escapeShellArg "${caddyCertificateDir}/${domain}.key"} \
            ${lib.escapeShellArg "${wingsCertificateDir}/${domain}.key"}
          exit 0
        fi
        sleep 2
      done

      echo "Caddy certificate for ${domain} is not available" >&2
      exit 1
    '';
  };
in {
  systemd = {
    services = {
      calagopus-wings = {
        after = ["calagopus-wings-cert-install.service"];
        requires = ["calagopus-wings-cert-install.service"];
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
}
