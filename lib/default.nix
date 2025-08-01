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
    cfgDir: cfgFile: templateFile:
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/${cfgDir}/${cfgFile}" ]; then
        mkdir -p "$HOME/${cfgDir}"
        cp "${templateFile}" "$HOME/${cfgDir}/${cfgFile}"
      fi
    '';
  mutableDottext =
    cfgDir: cfgFile: text:
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/${cfgDir}/${cfgFile}" ]; then
        mkdir -p "$HOME/${cfgDir}"
        echo "${text}" > "$HOME/${cfgDir}/${cfgFile}"
      fi
    '';
  replaceFile =
    cfgDir: cfgFile: file:
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -f "$HOME/${cfgDir}/${cfgFile}" ]; then
        if [ ! -f "$HOME/${cfgDir}/${cfgFile}.bak" ]; then
          mv "$HOME/${cfgDir}/${cfgFile}" "$HOME/${cfgDir}/${cfgFile}.bak"
        fi
        cp "${file}" "$HOME/${cfgDir}/${cfgFile}"
        chmod 755 "$HOME/${cfgDir}/${cfgFile}"
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
