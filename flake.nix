{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nvim.url = "github:bauers-lab-jared/nixvim";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: let
    out = system: let
      pkgs = nixpkgs.legacyPackages.${system};
      appliedOverlay = self.overlays.default pkgs pkgs;
    in {
      packages.default = appliedOverlay.default;
      devShells.default = pkgs.mkShell {
        inherit (appliedOverlay.default) nativeBuildInputs buildInputs;

        packages = [
          self.inputs.nvim.packages.${system}.nvim-odin
        ];
      };
    };
  in
    flake-utils.lib.eachDefaultSystem out
    // {
      overlays.default = final: prev: {
        default = final.callPackage ./default.nix {};
      };
    };
}
