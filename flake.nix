{
  description = "A very basic flake";

  outputs = {nixpkgs, ...}: let
    inherit (nixpkgs) lib;
    genSystems = lib.genAttrs [
      # Add more systems if they are supported
      "aarch64-linux"
      "x86_64-linux"
    ];
    pkgsFor = genSystems (system: nixpkgs.legacyPackages.${system});
  in {
    packages = genSystems (system: let
      pkgs = pkgsFor.${system};
    in {
      default = pkgs.flutter.buildFlutterApplication {
        pname = "flutter-hello";
        version = "1.0";
        src = ./.;
        vendorHash = "";
        meta = {};
      };
    });

    devShells = genSystems (
      system: {
        default = pkgsFor.${system}.mkShell {
          nativeBuildInputs = with pkgsFor.${system}; [
            flutter
            # I think these are already included, should check later:

            clang
            cmake
            gtk2
            graphite2
            gtk3
            ninja
            pkg-config
            xz
          ];
        };
      }
    );
  };
}
