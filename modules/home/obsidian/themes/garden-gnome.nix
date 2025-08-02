{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "garden-gnome-obsidian";
  version = "0.1.5";

  src = pkgs.fetchFromGitHub {
    owner = "theepicviolin";
    repo = "garden-gnome-obsidian";
    rev = version;
    sha256 = "sha256-BTWIM24FhjU6Qk21LFky3EQ44dTV2kTj/JGr+/QjeUs=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out
    cp $src/theme.css $out
    cp $src/manifest.json $out
  '';
}
