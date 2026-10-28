{pkgs, ...}: {
  home.packages = with pkgs; [
    python3
    nodejs_24
    bun
    nixd
    alejandra
    caddy
  ];

  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true;
    profiles.default = {
      userSettings = {
        "python.analysis.typeCheckingMode" = "basic";
        "workbench.colorTheme" = "Catppuccin Mocha";
        "workbench.iconTheme" = "catppuccin-mocha";
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
        "nix.serverSettings".nixd.formatting.command = ["${pkgs.alejandra}/bin/alejandra"];
        "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
        "caddyfile.executable" = "${pkgs.caddy}/bin/caddy";
      };
      extensions = with pkgs.vscode-extensions; [
        ms-python.python
        ms-python.vscode-pylance
        ms-python.debugpy
        mikestead.dotenv
        jnoortheen.nix-ide
        matthewpi.caddyfile-support
        ecmel.vscode-html-css
        unifiedjs.vscode-mdx
        catppuccin.catppuccin-vsc
        catppuccin.catppuccin-vsc-icons
      ];
    };
  };
}
