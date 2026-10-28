{
  lib,
  pkgs,
  ...
}: {
  home.activation.soberGameMode = lib.hm.dag.entryAfter ["writeBoundary"] ''
    config="$HOME/.var/app/org.vinegarhq.Sober/config/sober/config.json"
    mkdir -p "$(dirname "$config")"

    if [ -f "$config" ]; then
      ${pkgs.gnused}/bin/sed '/^[[:space:]]*\/\//d' "$config" \
        | ${pkgs.jq}/bin/jq '.enable_gamemode = true' > "$config.tmp" \
        || printf '%s\n' '{"enable_gamemode":true}' > "$config.tmp"
    else
      printf '%s\n' '{"enable_gamemode":true}' > "$config.tmp"
    fi

    mv "$config.tmp" "$config"
  '';
}
