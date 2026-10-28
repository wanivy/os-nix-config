{pkgs, ...}: {
  programs = {
    steam = {
      enable = true;
      extraPackages = [pkgs.gamemode];
      package = pkgs.steam.override {
        buildFHSEnv = args:
          pkgs.buildFHSEnv (args
            // {
              extraBuildCommands =
                (args.extraBuildCommands or "")
                + ''
                  rm -f $out/usr/sbin/ldconfig
                  cp ${pkgs.glibc.bin}/bin/ldconfig $out/usr/sbin/ldconfig
                '';
            });
      };
    };
    gamemode.enable = true;
  };

  users.users.yanville.extraGroups = ["gamemode"];
}
