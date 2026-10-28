{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  appimageTools,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  bluez,
}: let
  pname = "womic";
  version = "0-unstable";
  src = fetchurl {
    url = "https://wolicheng.com/womic/softwares/micclient-x86_64.AppImage";
    hash = "sha256-6g7IhgHWncuqImuUwfmDefkMEWqp5+3y/RJHviV+Hbs=";
  };
in
  stdenvNoCC.mkDerivation {
    inherit pname version;
    src = appimageTools.extractType2 {inherit pname version src;};

    nativeBuildInputs = [autoPatchelfHook makeWrapper];
    buildInputs = [alsa-lib bluez stdenv.cc.cc.lib];
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 usr/bin/micclient "$out/bin/womic"
      wrapProgram "$out/bin/womic" --set PIPEWIRE_LATENCY "1024/48000"
      runHook postInstall
    '';

    meta = {
      description = "Use a phone as a microphone over Wi-Fi or Bluetooth";
      homepage = "https://wolicheng.com/womic/wo_mic_linux.html";
      license = lib.licenses.unfree;
      platforms = ["x86_64-linux"];
      mainProgram = "womic";
    };
  }
