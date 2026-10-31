{pkgs, ...}: {
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    settings.mysqld = {
      bind-address = "127.0.0.1,172.18.0.1";
      port = 3306;
      skip-name-resolve = true;
    };
  };
}
