{pkgs, ...}: let
  flclash = pkgs.flclash.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace lib/common/path.dart \
          --replace-fail "return join(executableDirPath, 'FlClashCore\$executableExtension');" \
          "return '/run/wrappers/bin/FlClashCore';"

        substituteInPlace lib/common/system.dart \
          --replace-fail "if (output.startsWith('root:') && output.contains('rws')) {" \
          "if (output.startsWith('root:') && output.contains('rws') || corePath == '/run/wrappers/bin/FlClashCore') {"
      '';
  });
in {
  environment.systemPackages = [flclash];

  boot.kernelModules = ["tun"];
  networking.firewall = {
    checkReversePath = "loose";
    trustedInterfaces = ["FlClash"];
  };
  users.groups.flclash = {};
  users.users.yanville.extraGroups = ["flclash"];

  security.wrappers.FlClashCore = {
    source = "${pkgs.flclash.core}/bin/FlClashCore";
    owner = "root";
    group = "flclash";
    permissions = "u+rx,g+rx,o-rwx";
    setuid = true;
  };
}
