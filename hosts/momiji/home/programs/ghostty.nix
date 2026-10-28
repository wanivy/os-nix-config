{
  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings.theme = "pastel-pink";

    themes.pastel-pink = {
      background = "211820";
      foreground = "f3dfe8";
      cursor-color = "f4a7c3";
      selection-background = "5a3b4e";
      selection-foreground = "fff1f6";
      palette = [
        "0=#2a2028"
        "1=#e991a8"
        "2=#b8d8ba"
        "3=#ead3a6"
        "4=#aec6e8"
        "5=#e6a8d1"
        "6=#acd8d3"
        "7=#eadde4"
        "8=#725b69"
        "9=#f3a1b8"
        "10=#c9e4c5"
        "11=#f3dfb4"
        "12=#bfd5f1"
        "13=#f3b7de"
        "14=#bde5df"
        "15=#fff2f7"
      ];
    };
  };

  xdg.terminal-exec = {
    enable = true;
    settings = {
      default = ["com.mitchellh.ghostty.desktop"];
      GNOME = ["com.mitchellh.ghostty.desktop"];
    };
  };

  dconf.settings = {
    "org/gnome/desktop/default-applications/terminal" = {
      exec = "xdg-terminal-exec";
      exec-arg = "--";
    };
    "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
      "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ghostty/"
    ];
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/ghostty" = {
      name = "Open Ghostty";
      command = "ghostty";
      binding = "<Shift>F10";
    };
  };
}
