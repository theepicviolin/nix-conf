{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  pname = "obsidian-style-settings";
  version = "1.0.9";

  src = ./obsidian-style-settings.tar.xz;

  installPhase = ''
    mkdir -p $out
    cp ./manifest.json $out/manifest.json
    cp ./main.js $out/main.js
    cp ./styles.css $out/styles.css
  '';
}
