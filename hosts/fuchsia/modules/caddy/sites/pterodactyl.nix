{config, ...}: {
  services.caddy.virtualHosts = {
    "manage.wanivy.com".extraConfig = ''
      root * ${config.services.pterodactyl.panel.package}/public
      encode zstd gzip
      php_server
    '';

    "node.wanivy.com".extraConfig = ''
      respond "ok" 200
    '';
  };
}
