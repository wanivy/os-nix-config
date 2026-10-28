{
  config,
  lib,
  pkgs,
  ...
}: let
  catppuccin = pkgs.callPackage ../../packages/catppuccin-jetbrains {};
  minecraft-development = pkgs.fetchzip {
    url = "https://plugins.jetbrains.com/files/8327/1196534/Minecraft_Development-2026.2-1.9.0.zip";
    hash = "sha256-2Wq/lTnkoPIktUJlkGXcpAbWrsis7BML+swchGEAvaE=";
  };
  idea = pkgs.jetbrains.plugins.addPlugins pkgs.jetbrains.idea [
    catppuccin
    minecraft-development
  ];
  defaults = pkgs.callPackage ../../packages/idea-settings {};
  optionsDirectory = "${config.xdg.configHome}/JetBrains/IntelliJIdea${lib.versions.majorMinor idea.version}/options";
in {
  home.packages = [idea];

  home.activation.intellijIdeaSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
    for name in jdk.table.xml ui.lnf.xml laf.xml editorColors.xml; do
      target=${lib.escapeShellArg optionsDirectory}/"$name"
      if [[ ! -e "$target" && ! -L "$target" ]]; then
        run ${pkgs.coreutils}/bin/install -Dm600 "${defaults}/$name" "$target"
      fi
    done
  '';
}
