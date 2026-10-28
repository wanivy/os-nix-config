{
  pkgs,
  spicetify,
  ...
}: {
  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicetify.legacyPackages.${pkgs.stdenv.hostPlatform.system}.extensions; [
      trashbin
      adblock
      volumePercentage
      sidebarCustomizer
    ];
  };
}
