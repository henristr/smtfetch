{
  description = "smtfetch - display system information in the terminal";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.buildGoModule {
            pname = "smtfetch";
            version = "unstable";
            src = ./.;

            vendorHash = "sha256-ugU3BeI7jGWR9U0CE1jJpbVUM2/zu3aeA1AOZa/v2SI=";
            subPackages = [ "." ];

            meta = {
              description = "Display system information in the terminal";
              homepage = "https://github.com/henristr/smtfetch";
              license = pkgs.lib.licenses.mit;
              mainProgram = "smtfetch";
            };
          };
        });

      apps = forAllSystems (system:
        let
          package = self.packages.${system}.default;
        in
        {
          default = {
            type = "app";
            program = "${package}/bin/smtfetch";
          };
        });

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = [ pkgs.go ];
          };
        });
    };
}
