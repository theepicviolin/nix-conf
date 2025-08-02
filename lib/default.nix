{
  # This is the merged library containing your namespaced library as well as all libraries from
  # your flake's inputs.
  # lib,
  flake,

  # Your flake inputs are also available.
  inputs,
  self,

# The namespace used for your flake, defaulting to "internal" if not set.
# namespace,
}:
let
  # lib = flake.outputs.nixpkgs.lib;
  lib = inputs.nixpkgs.lib // inputs.home-manager.lib;
  # lib = inputs.home-manager.lib;
in
{
  # hm = inputs.home-manager.lib.hm;
  mutableDotfile =
    cfgPath: templateFile:
    let
      cfgDir = builtins.dirOf cfgPath;
    in
    (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/${cfgPath}" ]; then
        mkdir -p "$HOME/${cfgDir}"
        cp -r "${templateFile}" "$HOME/${cfgPath}"
        chmod +w "$HOME/${cfgPath}"
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

  enabled = {
    enable = true;
  };
  disabled = {
    enable = false;
  };
}
