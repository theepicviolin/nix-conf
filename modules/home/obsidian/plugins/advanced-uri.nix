{ pkgs, ... }:
pkgs.buildNpmPackage rec {
  pname = "obsidian-advanced-uri";
  version = "1.45.0";
  src = pkgs.fetchFromGitHub {
    owner = "Vinzent03";
    repo = "obsidian-advanced-uri";
    rev = version;
    hash = "sha256-/QVX+KmmilSnoUchOyR05+o2JHNwebQlXZF7lMxdIBo=";
  };

  npmDepsHash = "sha256-YasEfRVUVz4TzbFcNCNWJgzFBTMBY9EfP5ngcQK+ZmE=";
  makeCacheWritable = true;

  installPhase = ''
    mkdir -p $out
    cp ./manifest.json $out/manifest.json
    cp ./main.js $out/main.js
  '';
}
