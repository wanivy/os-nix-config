let
  keys = import ./hosts/keys.nix;
  recipients = [
    keys.fuchsia.yanville
    keys.fuchsia.host
  ];
in {
  "secrets/fuchsia/pterodactyl/app-key.age".publicKeys = recipients;
  "secrets/fuchsia/pterodactyl/hashids-salt.age".publicKeys = recipients;
  "secrets/fuchsia/pterodactyl/wings-token-id.age".publicKeys = recipients;
  "secrets/fuchsia/pterodactyl/wings-token.age".publicKeys = recipients;
  "secrets/fuchsia/calagopus/app-encryption-key.age".publicKeys = recipients;
}
