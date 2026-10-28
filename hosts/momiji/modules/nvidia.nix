{
  config,
  nixpkgs-unstable,
  ...
}: let
  nvidiaPackages = config.boot.kernelPackages.callPackage "${nixpkgs-unstable}/pkgs/os-specific/linux/nvidia-x11/default.nix" {};
in {
  services.xserver.videoDrivers = ["nvidia"];
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      open = true;
      package = nvidiaPackages.latest;
      modesetting.enable = true;
      powerManagement.enable = true;
      videoAcceleration = true;
    };
  };

  boot.extraModprobeConfig = ''
    options nvidia NVreg_TemporaryFilePath=/var/tmp
  '';
}
