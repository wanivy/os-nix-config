{pkgs, ...}: let
  bettbox = pkgs.callPackage ../packages/bettbox {};
in {
  environment.systemPackages = [bettbox];

  boot.kernelModules = ["tun"];
  networking.firewall = {
    checkReversePath = "loose";
    trustedInterfaces = ["Bettbox"];
  };

  security.wrappers.BettboxCore = {
    source = "${bettbox}/libexec/bettbox/BettboxCore";
    owner = "root";
    group = "flclash";
    permissions = "u+rx,g+rx,o-rwx";
    capabilities = "cap_net_admin,cap_net_bind_service,cap_net_raw+ep";
  };
}
