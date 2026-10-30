{pkgs, ...}: {
  services.irqbalance.enable = true;

  programs = {
    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraLibraries = packages: [packages.gamemode.lib];
      };
    };
    gamemode.enable = true;
  };

  users.users.yanville.extraGroups = ["gamemode"];
}
