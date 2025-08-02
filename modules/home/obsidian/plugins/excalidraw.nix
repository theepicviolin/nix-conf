{ pkgs, ... }:
pkgs.buildNpmPackage rec {
  pname = "obsidian-plugins-excalidraw";
  version = "2.14.0";
  src = pkgs.fetchFromGitHub {
    owner = "zsviczian";
    repo = "obsidian-excalidraw-plugin";
    rev = version;
    hash = "sha256-QUPL9WYpfhFf5yFZA7Hh1fGdFxiCwdVMZ6OeF7lypso=";
  };
  npmDepsHash = "sha256-zfLHskffLfsJoQ2Ftu30wjZ+d3t3C8HqSTUyEHP0NAQ=";

  makeCacheWritable = true;
  preBuild =
    let
      mathjax = pkgs.buildNpmPackage {
        pname = "mathjax-to-svg";
        version = "1.0.0";
        src = src + "/MathjaxToSVG";
        npmDepsHash = "sha256-AosKWlX08dpXNQ2YlrfR6jEInmU02Ztf26nmV19Jxok=";
      };
    in
    ''
      mkdir -p ./MathjaxToSVG/dist
      cp -r ${mathjax}/lib/node_modules/@zsviczian/mathjax-to-svg/dist/index.js ./MathjaxToSVG/dist/index.js
    '';

  installPhase = ''
    mkdir -p $out
    cp ./dist/* $out
  '';
}
