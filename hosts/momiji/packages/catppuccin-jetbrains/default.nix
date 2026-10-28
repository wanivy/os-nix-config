{
  fetchurl,
  lib,
}: let
  version = "3.6.1";
in
  fetchurl {
    name = "catppuccin-theme-${version}.jar";
    url = "https://github.com/catppuccin/jetbrains/releases/download/v${version}/Catppuccin.Theme-${version}.jar";
    hash = "sha256-OhEE4NtT/1uiFslMnnMKhcesKEf05f6C2RuZ3JEEX/8=";

    meta = {
      description = "Catppuccin theme for JetBrains IDEs";
      homepage = "https://github.com/catppuccin/jetbrains";
      license = lib.licenses.mit;
    };
  }
