{
  config,
  pkgs,
  ...
}: let
  email = "yamqsaya@gmail.com";
  publicKey = builtins.readFile ../../keys/yanville.pub;
in {
  home.file.".ssh/id_ed25519.pub".source = ../../keys/yanville.pub;

  programs.git = {
    enable = true;
    signing = {
      format = "ssh";
      key = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    settings = {
      core.sshCommand = "ssh -F /dev/null -i ${config.home.homeDirectory}/.ssh/id_ed25519 -o AddKeysToAgent=yes -o IdentitiesOnly=yes";
      user = {
        name = "wanivy";
        inherit email;
      };
      gpg.ssh.allowedSignersFile = toString (pkgs.writeText "git-allowed-signers" "${email} ${publicKey}");
    };
  };
}
