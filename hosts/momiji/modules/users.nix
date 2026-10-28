{pkgs, ...}: {
  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      root.openssh.authorizedKeys.keyFiles = [../keys/yanville.pub];
      yanville = {
        isNormalUser = true;
        extraGroups = ["wheel" "networkmanager"];
        openssh.authorizedKeys.keyFiles = [../keys/yanville.pub];
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
