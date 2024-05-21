{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }: let
    out = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      appliedOverlay = self.overlays.default pkgs pkgs;
    in {
      packages.default = appliedOverlay.default;
    };
  in
    flake-utils.lib.eachDefaultSystem out
    // {
      overlays.default = final: prev: {
        default = final.callPackage ./default.nix {};
      };
    };
}
