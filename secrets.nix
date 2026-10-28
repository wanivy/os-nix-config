let
  yanville = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO3GjcUT4hKEmqVg4DaJhdySRWNdRYgqfleaP2p/aK3b yanville@fuchsia";
  fuchsia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBVQcqst4mLA3dmCCHHIfGndv86BewtxU/Wt7zN5URGf";
  recipients = [
    yanville
    fuchsia
  ];
in {
  "secrets/fuchsia/pterodactyl/app-key.age".publicKeys = recipients;
  "secrets/fuchsia/pterodactyl/hashids-salt.age".publicKeys = recipients;
  "secrets/fuchsia/pterodactyl/wings-token-id.age".publicKeys = recipients;
  "secrets/fuchsia/pterodactyl/wings-token.age".publicKeys = recipients;
}
