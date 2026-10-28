{pkgs, ...}: let
  keys = import ../../keys.nix;
in {
  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      root.openssh.authorizedKeys.keys = [keys.momiji.yanville];
      yanville = {
        isNormalUser = true;
        extraGroups = ["wheel" "networkmanager"];
        openssh.authorizedKeys.keys = [keys.momiji.yanville];
      };
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };
}
