{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true;

  boot = {
    kernelPackages = pkgs.linuxPackages;
    loader = {
      efi.canTouchEfiVariables = true;
      timeout = 5;
    };
  };

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  time.timeZone = "Europe/Kyiv";
  i18n = {
    defaultLocale = "en_US.UTF-8";

    extraLocaleSettings = {
      LC_TIME = "ru_RU.UTF-8";
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
    };
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      max-jobs = 2;
      cores = 6;
      auto-optimise-store = true;

      min-free = 3 * 1024 * 1024 * 1024;
      max-free = 8 * 1024 * 1024 * 1024;
    };

    daemonCPUSchedPolicy = "batch";
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  systemd.services.nix-daemon.serviceConfig = {
    CPUWeight = 50;
    IOWeight = 50;
  };

  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };
  services.fstrim.enable = true;

  programs = {
    mtr.enable = true;
    zsh.enable = true;
    nh = {
      enable = true;
      flake = "/home/yanville/nixos";
    };
  };

  environment.systemPackages = with pkgs; [git vim nano pciutils usbutils iperf3 ntfs3g];
}
