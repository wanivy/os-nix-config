{
  config,
  lib,
  pkgs,
  ...
}: let
  wayclip-daemon = pkgs.callPackage ../../packages/wayclip-daemon {};
  wayclip-toggle = pkgs.writeShellApplication {
    name = "wayclip-toggle";
    runtimeInputs = [pkgs.libnotify pkgs.systemd];
    text = ''
      if systemctl --user is-active --quiet wayclip-daemon.service; then
        systemctl --user stop wayclip-daemon.service
        notify-send "Wayclip" "Recording stopped"
      else
        systemctl --user start wayclip-daemon.service
        notify-send "Wayclip" "Recording started"
      fi
    '';
  };
in {
  home.packages = [wayclip-daemon wayclip-toggle];

  home.activation.wayclipShortcut = lib.hm.dag.entryAfter ["writeBoundary"] ''
    settingsPath="${config.xdg.configHome}/wayclip/config.json"
    if [[ -f "$settingsPath" ]]; then
      ${pkgs.jq}/bin/jq '.shortcuts.save_clip = "ALT+z"' "$settingsPath" > "$settingsPath.tmp"
      mv "$settingsPath.tmp" "$settingsPath"
    fi
  '';

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = lib.mkAfter [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/wayclip-toggle/"
    ];
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/wayclip-toggle" = {
      name = "Toggle Wayclip recording";
      command = lib.getExe wayclip-toggle;
      binding = "<Ctrl><Alt>z";
    };
  };

  systemd.user.services.wayclip-daemon = {
    Unit = {
      Description = "Wayclip background recording daemon";
      Documentation = "https://github.com/Wayclip/daemon";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      ExecStart = lib.getExe wayclip-daemon;
      Restart = "on-failure";
      RestartSec = 5;
    };

    Install.WantedBy = ["graphical-session.target"];
  };
}
