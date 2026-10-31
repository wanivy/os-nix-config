let
  keys = import ./hosts/keys.nix;
  recipients = [
    keys.fuchsia.yanville
    keys.fuchsia.host
  ];
in {
  "secrets/fuchsia/calagopus/app-encryption-key.age".publicKeys = recipients;
  "secrets/fuchsia/calagopus/wings-token-id.age".publicKeys = recipients;
  "secrets/fuchsia/calagopus/wings-token.age".publicKeys = recipients;
}
