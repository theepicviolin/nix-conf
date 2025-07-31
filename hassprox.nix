let
  pkgs = import <nixpkgs> { };
  vmid = "100"; # toString inputs.vmid;
  diskid = "0"; # toString inputs.diskid;
  outdir = "/var/lib/vz/images/${vmid}";
  outpath = outdir + "/vm-${vmid}-disk-${diskid}.raw";
  file = "local:${vmid}/vm-${vmid}-disk-${diskid}.raw";
in
pkgs.stdenv.mkDerivation rec {
  pname = "hass-import";
  version = "16.0";
  src = pkgs.fetchurl {
    url = "https://github.com/home-assistant/operating-system/releases/download/${version}/haos_ova-${version}.qcow2.xz";
    sha256 = "sha256-JMXzBhnaWthTTWFQI2JjYXg8dDa2fAav5TtYpP9s1rU=";
  };
  buildInputs = [
    pkgs.xz
    pkgs.qemu-utils
  ];

  unpackPhase = ''
    mkdir -p $out
    unxz -k ${src} --stdout > $out/src.qcow2
  '';

  postFetch = ''

  '';

  installPhase = ''
    #mkdir -p ${outdir}
    #qemu-img convert src.qcow2 -O raw "${outpath}"
    #echo ${file} > $out
    qemu-img convert $out/src.qcow2 -O raw $out/src.raw
  '';

  # mkdir -p ${outdir}
  # qemu-img convert src.xz -O raw "${outpath}"
}
