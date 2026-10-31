{...}: {
  services.caddy.virtualHosts = {
    "manage.wanivy.com".extraConfig = ''
      encode zstd gzip
      reverse_proxy 127.0.0.1:8000
    '';

    "node.wanivy.com".extraConfig = ''
      respond "ok" 200
    '';
  };
}
