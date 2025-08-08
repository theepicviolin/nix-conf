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
    lib.foldlAttrs (
      acc: app: mimes:
      acc // lib.foldl (acc: mime: acc // { ${mime} = [ app ]; }) { } mimes
    ) { } appMimeMap;

  secret = name: ../secrets/${name}.age;

  thisSystemUsers =
    hostName: system:
    lib.filterAttrs (
      name: _: lib.elemAt (lib.splitString "@" name) 1 == hostName
    ) flake.outputs.legacyPackages.${system}.homeConfigurations;

  anyUser =
    {
      hostName,
      system,
      pred,
    }:
    lib.any (user: pred user.config) (lib.attrValues (flake.lib.thisSystemUsers hostName system));

  matchingUsers =
    {
      hostName,
      system,
      pred,
    }:
    flake.lib.thisSystemUsers hostName system
    |> lib.filterAttrs (name: value: (pred value.config))
    |> lib.attrNames
    |> map (u: lib.elemAt (lib.splitString "@" u) 0);

  enabled = {
    enable = true;
  };
  disabled = {
    enable = false;
  };
}
