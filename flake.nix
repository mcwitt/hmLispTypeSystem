{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
      forAllSystems' = nixpkgs.lib.genAttrs systems;

      packageName = "hmLispTypeSystem";

      mkPkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            (self: _: {
              myHaskellPackages = self.haskell.packages.ghc912.override (old: {
                overrides = self.lib.composeExtensions (old.overrides or (_: _: { })) (
                  hself: _: {

                    ${packageName} = hself.callCabal2nix packageName ./. {
                      verset = hself.verset_0_0_1_11;
                    };

                    verset_0_0_1_11 = hself.callHackageDirect {
                      pkg = "verset";
                      ver = "0.0.1.11";
                      sha256 = "sha256-Pma1h7uKkayx+CUigsnt9De8jMdazvRaKxE+rDlKIJo=";
                    } { };
                  }
                );
              });
            })
          ];
        };

      forAllSystems = f: forAllSystems' (system: f (mkPkgs system) system);
    in
    {
      packages = forAllSystems (
        pkgs: _: {
          default = pkgs.myHaskellPackages.${packageName};
        }
      );

      devShells = forAllSystems (
        pkgs: system: {
          default = pkgs.myHaskellPackages.shellFor {
            packages = ps: [ ps.${packageName} ];
          };
        }
      );
    };
}
