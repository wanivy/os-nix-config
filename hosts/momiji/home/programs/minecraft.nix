{
  pkgs,
  freesm,
  ...
}: let
  java21 = pkgs.jdk21;
  java25 = pkgs.jdk25;
in {
  programs.java = {
    enable = true;
    package = java21;
  };

  home = {
    packages = [
      (freesm.packages.${pkgs.stdenv.hostPlatform.system}.freesmlauncher.override {
        jdks = [java21 java25];
      })
    ];
    file = {
      ".jdks/java-21".source = java21.home;
      ".jdks/java-25".source = java25.home;
    };
    sessionVariables = {
      JAVA_21_HOME = java21.home;
      JAVA_25_HOME = java25.home;
    };
  };

  programs.zsh.shellAliases = {
    java21 = "${java21}/bin/java";
    java25 = "${java25}/bin/java";
  };
}
