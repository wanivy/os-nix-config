{lib, ...}: {
  services.postgresql = {
    enable = true;
    settings.listen_addresses = lib.mkForce "127.0.0.1,172.18.0.1";
    authentication = lib.mkAfter ''
      host all all 144.31.203.21/32 scram-sha-256
      host all all 172.18.0.0/16 scram-sha-256
    '';
    ensureDatabases = ["calagopus"];
    ensureUsers = [
      {
        name = "calagopus";
        ensureDBOwnership = true;
      }
    ];
  };
}
