{pkgs, ...}: let
  keys = import ../keys.nix;
in {
  imports = [
    ./hardware.nix
    ./networking.nix
    ./modules/calagopus
    ./modules/caddy/sites/calagopus.nix
    ./modules/mariadb
    ./modules/postgresql
  ];

  boot.loader = {
    grub = {
      enable = true;
      efiSupport = false;
    };

    systemd-boot.enable = false;
    efi.canTouchEfiVariables = false;
  };

  networking.hostName = "fuchsia";

  time.timeZone = "Etc/UTC";
  i18n.defaultLocale = "C.UTF-8";

  users.users.yanville = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [keys.fuchsia.yanville];
  };

  users.users.trwz = {
    isNormalUser = true;
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [keys.fuchsia.trwz];
  };

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "clean";
      plugins = ["git"];
      preLoaded = ''
        [[ $USER == trwz ]] && ZSH_THEME="bira"
      '';
    };
  };

  systemd.tmpfiles.rules = [
    "f /home/yanville/.zshrc 0644 yanville users - -"
    "f /home/trwz/.zshrc 0644 trwz users - -"
  ];

  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
    };
  };

  services.qemuGuest.enable = true;
  services.fstrim.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    fastfetch
    git
    ghostty.terminfo
    htop
    iperf3
    mtr
    nano
    rclone
    vim
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = ["yanville"];
  };

  system.stateVersion = "26.05";
}
