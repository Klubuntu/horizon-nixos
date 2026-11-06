{
  description = "Horizon Launcher";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { 
          inherit system; 
          config.allowUnfree = true;
        };
      in
      {
        packages = {
          horizon-launcher-tar = pkgs.callPackage ./horizon-launcher-tar.nix { };
          horizon-launcher-appimage = pkgs.callPackage ./horizon-launcher-appimage.nix { };
          default = self.packages.${system}.horizon-launcher-tar;
        };

        apps = {
          horizon-launcher-tar = {
            type = "app";
            program = "${self.packages.${system}.horizon-launcher-tar}/bin/horizon-launcher";
          };
          horizon-launcher-appimage = {
            type = "app";
            program = "${self.packages.${system}.horizon-launcher-appimage}/bin/horizon-launcher";
          };
          default = self.apps.${system}.horizon-launcher-tar;
        };
      });
}
