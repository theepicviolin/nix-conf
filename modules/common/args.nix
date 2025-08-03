{
  inputs,
  pkgs,
  flake,
  hostName,
  ...
}:
{
  _module.args.pkgs-stable = import inputs.nixpkgs-stable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
  _module.args.pkgs-unstable = import inputs.nixpkgs-unstable {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };
  _module.args.osConfig = flake.outputs.nixosConfigurations.${hostName}.config;
}
