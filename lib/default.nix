{
  flake,
  inputs,
  ... # self is the only other input
}:
let
  lib = inputs.nixpkgs.lib // inputs.home-manager.lib;
in
{
  mutableDotfile =
    cfgPath: templateFile:
    let
      cfgDir = builtins.dirOf cfgPath;
    in
    (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -e "$HOME/${cfgPath}" ]; then
        mkdir -p "$HOME/${cfgDir}"
        cp -r "${templateFile}" "$HOME/${cfgPath}"
        chmod +w -R "$HOME/${cfgPath}"
      fi
    '');
  mutableDottext =
    cfgPath: text:
    let
      cfgDir = builtins.dirOf cfgPath;
    in
    (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/${cfgPath}" ]; then
        mkdir -p "$HOME/${cfgDir}"
        echo "${text}" > "$HOME/${cfgPath}"
      fi
    '');
  replaceFile =
    cfgPath: file:
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -f "$HOME/${cfgPath}" ]; then
        if [ ! -f "$HOME/${cfgPath}.bak" ]; then
          mv "$HOME/${cfgPath}" "$HOME/${cfgPath}.bak"
        fi
        cp "${file}" "$HOME/${cfgPath}"
        chmod 755 "$HOME/${cfgPath}"
      fi
    '';

  mimeToAppMap =
    appMimeMap:
    (builtins.foldl' (
      acc: app:
      acc
      // builtins.listToAttrs (
        map (mime: {
          name = mime;
          value = [ app ];
        }) appMimeMap.${app}
      )
    ) { } (builtins.attrNames appMimeMap));

  secret = name: ../secrets/${name}.age;

  getUser = name: lib.elemAt (lib.splitString "@" name) 0;
  getHost = name: lib.elemAt (lib.splitString "@" name) 1;

  anyUser =
    {
      hostName,
      system,
      pred,
    }:
    let
      thisSystemUsers = lib.filterAttrs (
        name: _: flake.lib.getHost name == hostName
      ) flake.outputs.legacyPackages.${system}.homeConfigurations;
    in
    builtins.any (user: pred user.config) (builtins.attrValues thisSystemUsers);

  matchingUsers =
    {
      hostName,
      system,
      pred,
    }:
    map (u: flake.lib.getUser u) (
      lib.attrNames (
        lib.filterAttrs (
          name: value: ((flake.lib.getHost name) == hostName) && (pred value.config)
        ) flake.outputs.legacyPackages.${system}.homeConfigurations
      )
    );

  enabled = {
    enable = true;
  };
  disabled = {
    enable = false;
  };
}
