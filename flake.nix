{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixvim.url = "github:bauers-lab-jared/nixvim/flake-restructure";
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

        packages = let
          inherit (self.inputs.nixvim) packages nixosModules;
          username = nixpkgs.lib.removeSuffix "\n" (builtins.readFile ./.user);

          nixvim-base =
            if username != ""
            then packages.${system}.nixvim.nixvimExtend nixosModules."user-${username}"
            else packages.${system}.nixvim;

          nixvim =
            (nixvim-base.nixvimExtend nixosModules.proj-odin).nixvimExtend
            {
              # project specific config here
            };
        in [
          nixvim
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
