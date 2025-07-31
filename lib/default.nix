{
  # This is the merged library containing your namespaced library as well as all libraries from
  # your flake's inputs.
  lib,

  # Your flake inputs are also available.
  inputs,

  # The namespace used for your flake, defaulting to "internal" if not set.
  namespace,
}:
{
  mutableDotfile =
    cfgDir: cfgFile: templateFile:
    lib.home-manager.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/${cfgDir}/${cfgFile}" ]; then
        mkdir -p "$HOME/${cfgDir}"
        cp "${templateFile}" "$HOME/${cfgDir}/${cfgFile}"
      fi
    '';
  mutableDottext =
    cfgDir: cfgFile: text:
    lib.home-manager.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -f "$HOME/${cfgDir}/${cfgFile}" ]; then
        mkdir -p "$HOME/${cfgDir}"
        echo "${text}" > "$HOME/${cfgDir}/${cfgFile}"
      fi
    '';
  replaceFile =
    cfgDir: cfgFile: file:
    lib.home-manager.hm.dag.entryAfter [ "writeBoundary" ] ''
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

  notifyUserTarget =
    {
      pkgs,
      username,
      name,
      delay,
    }:
    pkgs.writeShellScript "notify-${name}" ''
      set -e
      _USER="${username}"  # Change if needed
      _UID=$(id -u "$_USER")
      export XDG_RUNTIME_DIR="/run/user/$_UID"

      if loginctl show-user "$_USER" | grep -q "State=active"; then
        sleep ${delay}
        systemctl --user -M "$_USER@" start ${name}.target
      fi
    '';

  enabled = {
    enable = true;
  };
  disabled = {
    enable = false;
  };
}
