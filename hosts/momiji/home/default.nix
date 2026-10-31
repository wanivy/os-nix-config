{
  agenix,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./programs/zen-browser.nix
    ./programs/ghostty.nix
    ./programs/discord.nix
    ./programs/easyeffects.nix
    ./programs/git.nix
    ./programs/spicetify.nix
    ./programs/minecraft.nix
    ./programs/vscode.nix
    ./programs/intellij-idea.nix
    ./programs/libreoffice.nix
    ./programs/thunderbird.nix
    ./programs/sober.nix
  ];

  home = {
    username = "yanville";
    homeDirectory = "/home/yanville";
    stateVersion = "26.05";
    packages = with pkgs; [
      btop
      codex
      ayugram-desktop
      ente-auth
      eza
      keyguard
      mangohud
      ripgrep
      openssl
      agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    file.".local/share/Steam/package/beta".text = "publicbeta";
    file.".local/state/MangoHud/.keep".text = "";
  };

  xdg.configFile."MangoHud/MangoHud.conf".text = ''
    legacy_layout=0
    position=top-left
    fps
    frametime
    frame_timing
    cpu_stats
    gpu_stats
    ram
    vram
    histogram
    autostart_log=1
    log_duration=0
    output_folder=/home/yanville/.local/state/MangoHud
  '';

  programs = {
    home-manager.enable = true;
    fastfetch.enable = true;
    zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initContent = ''
        secret() (cd ~/nixos && EDITOR=nano agenix -e "secrets/$1.age" -i ~/.ssh/id_ed25519_fuchsia)
      '';
      shellAliases.deploy-fuchsia = "NH_SSHOPTS='-4 -F /dev/null -i /home/yanville/.ssh/id_ed25519_fuchsia -o IdentitiesOnly=yes' nh os switch path:/home/yanville/nixos --hostname fuchsia --target-host yanville@144.31.203.21 --elevation-strategy passwordless --ask";
      oh-my-zsh = {
        enable = true;
        theme = "clean";
        plugins = ["git"];
      };
    };
  };

  gtk = {
    enable = true;
    gtk3.extraCss = ''
      .view:selected {
        background-color: #d56199;
        color: #ffffff;
      }
    '';
  };

  dconf.settings = {
    "org/gnome/shell" = {
      always-show-log-out = true;
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        appindicator.extensionUuid
        clipboard-indicator.extensionUuid
        desktop-icons-ng-ding.extensionUuid
        emoji-copy.extensionUuid
      ];
    };
    "org/gnome/desktop/interface" = {
      accent-color = "pink";
      color-scheme = "prefer-dark";
    };
    "org/gnome/desktop/peripherals/mouse".accel-profile = "flat";
    "org/gnome/desktop/wm/preferences".button-layout = ":minimize,maximize,close";
    "org/gnome/desktop/input-sources" = {
      sources = [
        (lib.hm.gvariant.mkTuple ["xkb" "us"])
        (lib.hm.gvariant.mkTuple ["xkb" "ru"])
      ];
      xkb-options = ["grp:alt_shift_toggle"];
    };
  };
}
