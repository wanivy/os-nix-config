{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  writeShellScript,
  coreutils,
  libcap,
  gtk3,
  keybinder3,
  libayatana-appindicator,
}: let
  pname = "bettbox";
  version = "1.19.7";
  getcap = writeShellScript "bettbox-getcap" ''
    if [ "$#" -eq 1 ]; then
      target="$(${coreutils}/bin/readlink -f -- "$1")"
      exec ${libcap}/bin/getcap "$target"
    fi
    exec ${libcap}/bin/getcap "$@"
  '';
in
  stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://github.com/appshubcc/Bettbox/releases/download/v${version}/Bettbox-${version}-linux-amd64.deb";
      hash = "sha256-IKkpfoSQJjUYpGKfW9eiE4Ty7usH3EWZqOqZs1YIfYE=";
    };

    nativeBuildInputs = [dpkg autoPatchelfHook makeWrapper];
    buildInputs = [
      gtk3
      keybinder3
      libayatana-appindicator
      stdenv.cc.cc.lib
    ];

    # Bundled by Flutter's Android JNI dependency, but not loaded by the Linux app.
    autoPatchelfIgnoreMissingDeps = ["libjvm.so"];

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb --extract "$src" .
      runHook postUnpack
    '';

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"
      cp -r usr/* "$out/"

      mkdir -p "$out/bin" "$out/libexec/bettbox" "$out/libexec/bettbox-tools"
      mv "$out/share/Bettbox/BettboxCore" "$out/libexec/bettbox/BettboxCore"
      ln -s /run/wrappers/bin/BettboxCore "$out/share/Bettbox/BettboxCore"
      ln -s ${getcap} "$out/libexec/bettbox-tools/getcap"
      makeWrapper "$out/share/Bettbox/Bettbox" "$out/bin/Bettbox" \
        --prefix PATH : "$out/libexec/bettbox-tools"
      rm -r "$out/share/polkit-1"

      runHook postInstall
    '';

    meta = {
      description = "Better Network Toolbox based on Mihomo";
      homepage = "https://github.com/appshubcc/Bettbox";
      license = lib.licenses.gpl3Only;
      mainProgram = "Bettbox";
      platforms = ["x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
