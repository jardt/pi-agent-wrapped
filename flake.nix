{
  description = "Declarative, configurable Pi coding-agent wrappers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
    nix-wrapper-modules.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-wrapper-modules,
      ...
    }@inputs:
    let
      nixpkgsLib = nixpkgs.lib;
      systems = nixpkgsLib.systems.flakeExposed;
      forEachSystem = nixpkgsLib.genAttrs systems;
      wrapperModule = nixpkgsLib.modules.importApply ./module.nix inputs;
      wrapper = nix-wrapper-modules.lib.evalModule wrapperModule;
      mkProfile = import ./lib/mk-profile.nix {
        lib = nixpkgsLib;
        inherit wrapper;
      };
      homeManagerModule = nixpkgsLib.modules.importApply ./modules/home-manager.nix inputs;
    in
    {
      lib = {
        inherit mkProfile;
      };

      wrapperModules = {
        pi = wrapperModule;
        default = self.wrapperModules.pi;
      };

      wrappers = {
        pi = wrapper.config;
        default = self.wrappers.pi;
      };

      packages = forEachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        rec {
          pi = pkgs.callPackage ./packages/pi { };
          pi-agent-tools = pkgs.callPackage ./packages/pi-agent-tools.nix { };
          pi-resources = pkgs.callPackage ./packages/pi-resources.nix {
            piPackage = pi;
          };
          pi-fff = pkgs.callPackage ./packages/pi-packages/fff.nix { };
          pi-dynamic-workflows = pkgs.callPackage ./packages/pi-packages/dynamic-workflows.nix { };
          pi-codex-goal = pkgs.callPackage ./packages/pi-packages/codex-goal.nix { };
          pi-wrapped = self.wrappers.pi.wrap { inherit pkgs; };
          p = self.lib.mkProfile {
            inherit pkgs;
            profileName = "default";
            binName = "p";
          };
          default = p;
        }
      );

      apps = forEachSystem (system: rec {
        p = {
          type = "app";
          program = "${self.packages.${system}.p}/bin/p";
        };
        default = p;
      });

      nixosModules = {
        pi = nix-wrapper-modules.lib.getInstallModule {
          name = "pi";
          value = wrapperModule;
        };
        default = self.nixosModules.pi;
      };

      homeModules = {
        pi = homeManagerModule;
        profiles = homeManagerModule;
        wrapper = self.nixosModules.pi;
        default = self.homeModules.pi;
      };

      homeManagerModules = self.homeModules;

      devShells = forEachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            name = "pi-wrapped-module";
            packages = [
              self.packages.${system}.p
              self.packages.${system}.pi
              self.packages.${system}.pi-agent-tools
              self.packages.${system}.pi-resources
              self.packages.${system}.pi-fff
              self.packages.${system}.pi-dynamic-workflows
              self.packages.${system}.pi-codex-goal
            ];
          };
        }
      );

      formatter = forEachSystem (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.nixfmt-tree
      );
    };
}
