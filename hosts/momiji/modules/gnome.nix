{
  lib,
  pkgs,
  ...
}: {
  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  security.rtkit.enable = true;
  programs = {
    dconf.enable = true;
    nautilus-open-any-terminal = {
      enable = true;
      terminal = "ghostty";
    };
  };

  environment = {
    gnome.excludePackages = [pkgs.gnome-console];
    sessionVariables.NAUTILUS_4_EXTENSION_DIR = lib.mkForce "/run/current-system/sw/lib/nautilus/extensions-4";
  };

  fonts = {
    packages = [pkgs.twitter-color-emoji];
    fontconfig = {
      defaultFonts.emoji = ["Twitter Color Emoji"];
      localConf = ''
        <fontconfig>
          <alias binding="strong">
            <family>Noto Color Emoji</family>
            <prefer><family>Twitter Color Emoji</family></prefer>
          </alias>
        </fontconfig>
      '';
    };
  };

  environment.systemPackages = with pkgs.gnomeExtensions; [
    appindicator
    clipboard-indicator
    desktop-icons-ng-ding
    emoji-copy
  ];
}
