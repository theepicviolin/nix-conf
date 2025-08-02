{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "obsidian-file-diff";
  version = "1.1.1";

  src = pkgs.fetchFromGitHub {
    owner = "friebetill";
    repo = "obsidian-file-diff";
    rev = version;
    hash = "sha256-qzPN3dTCQe+4UYl4HTJfGhY9+9Zcku/SGB+AdpZ6TUU=";
  };

  offlineCache = pkgs.fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    hash = "sha256-mjIbVo3KIpIUAiNY0outD0dJHJBKAx4CpCgu721WcYg=";
  };

  nativeBuildInputs = with pkgs; [
    nodejs
    yarnConfigHook
    yarnBuildHook
    npmHooks.npmInstallHook
  ];

  installPhase = ''
    mkdir -p $out
    cp ./manifest.json $out/manifest.json
    cp ./main.js $out/main.js
    cp ./styles.css $out/styles.css
  '';
}
