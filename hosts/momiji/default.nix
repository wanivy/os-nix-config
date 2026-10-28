{
  imports = [
    ./hardware-configuration.nix
    ./modules/base.nix
    ./modules/nvidia.nix
    ./modules/power.nix
    ./modules/secure-boot.nix
    ./modules/gnome.nix
    ./modules/obs.nix
    ./modules/users.nix
    ./modules/gaming.nix
    ./modules/flclash.nix
    ./modules/localsend.nix
    ./modules/womic.nix
    ./modules/openrgb.nix
    ./modules/sober.nix
  ];

  networking.hostName = "momiji";
  system.stateVersion = "26.05";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.yanville = import ./home;
  };
}
