{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  alsa-lib,
  gst_all_1,
  libGL,
  libxcb,
  pipewire,
  systemd,
}: let
  brandingSrc = fetchFromGitHub {
    owner = "Wayclip";
    repo = "branding";
    rev = "2a9762853df371d84c7266febfde7baf0b79676a";
    hash = "sha256-1VPmzKnUPMESpeKb23AH5pHPHLGa533/rWRNIW8ON7k=";
  };
  coreSrc = fetchFromGitHub {
    owner = "Wayclip";
    repo = "core";
    rev = "41592c66cfc5111deaa21c186fa5753f30770a77";
    hash = "sha256-lueKpyBPuKZK65rEljqW6zsheDOC3BO8AUajY39NlYw=";
  };
  gstPlugins = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
  ];
in
  rustPlatform.buildRustPackage {
    pname = "wayclip-daemon";
    version = "0.2.0-unstable-2026-10-25";

    src = fetchFromGitHub {
      owner = "Wayclip";
      repo = "daemon";
      rev = "70627210c2a18e1c344aca355e7b858d548762c3";
      hash = "sha256-9l2SMPUMKBs60CnatW1anqwGTJ1LlNY2QYmB6mgq934=";
    };

    cargoHash = "sha256-6nGfgwii1h2N8W2kj1Qsz0REBkR9aoNwvqHWxuxY7eM=";

    postPatch = ''
      cp -r ${brandingSrc}/. branding/
      cp -r ${coreSrc} wayclip-core
      chmod -R u+w branding wayclip-core
      substituteInPlace Cargo.toml \
        --replace-fail \
          'wayclip-core = { version = "0.1.5", features = ["errors", "daemon"] }' \
          'wayclip-core = { path = "wayclip-core", features = ["errors", "daemon"] }'
      substituteInPlace wayclip-core/src/settings/shortcut.rs \
        --replace-fail "WayclipKeyCode::Char('c')" "WayclipKeyCode::Char('z')"
      substituteInPlace wayclip-core/assets/settings.toml \
        --replace-fail 'default = "ALT+c"' 'default = "ALT+z"'
    '';

    nativeBuildInputs = [
      makeWrapper
      pkg-config
      rustPlatform.bindgenHook
    ];

    buildInputs = [
      alsa-lib
      libGL
      libxcb
      pipewire
      systemd
    ] ++ gstPlugins;

    postFixup = ''
      wrapProgram $out/bin/wayclip-daemon \
        --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${lib.makeSearchPath "lib/gstreamer-1.0" gstPlugins}"
    '';

    meta = {
      description = "Background recording daemon for Wayclip";
      homepage = "https://github.com/Wayclip/daemon";
      license = lib.licenses.mit;
      mainProgram = "wayclip-daemon";
      platforms = lib.platforms.linux;
    };
  }
