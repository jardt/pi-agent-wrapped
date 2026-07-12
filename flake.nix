{
  description = "Declarative Pi coding-agent setup packaged with nix-wrapper-modules";

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
      lib = nixpkgs.lib;
      systems = lib.systems.flakeExposed;
      forEachSystem = lib.genAttrs systems;
      wrapperModule = lib.modules.importApply ./module.nix inputs;
      personalWrapperModule = {
        imports = [
          wrapperModule
          ./presets/personal.nix
        ];
      };
      wrapper = nix-wrapper-modules.lib.evalModule wrapperModule;
      personalWrapper = nix-wrapper-modules.lib.evalModule personalWrapperModule;
    in
    {
      # `pi` is the generic, unopinionated module; `personal` layers
      # presets/personal.nix on top of it. Every `default` alias points at
      # `personal` to keep existing consumers of this flake unchanged.
      wrapperModules = {
        pi = wrapperModule;
        personal = personalWrapperModule;
        default = self.wrapperModules.personal;
      };

      wrappers = {
        pi = wrapper.config;
        personal = personalWrapper.config;
        default = self.wrappers.personal;
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
          pi-wrapped = self.wrappers.personal.wrap { inherit pkgs; };
          pi-minimal-wrapped =
            (self.wrappers.personal.extendModules {
              modules = [
                ./profiles/minimal.nix
                { binName = "p-minimal"; }
              ];
            }).config.wrap
              { inherit pkgs; };
          p = pkgs.runCommand "pi-wrapped-p-only" { } ''
            mkdir -p $out/bin
            ln -s ${pi-wrapped}/bin/p $out/bin/p
          '';
          p-minimal = pkgs.runCommand "pi-wrapped-p-minimal-only" { } ''
            mkdir -p $out/bin
            ln -s ${pi-minimal-wrapped}/bin/p-minimal $out/bin/p-minimal
          '';
          default = p;
        }
      );

      apps = forEachSystem (system: rec {
        p = {
          type = "app";
          program = "${self.packages.${system}.p}/bin/p";
        };
        p-minimal = {
          type = "app";
          program = "${self.packages.${system}.p-minimal}/bin/p-minimal";
        };
        default = p;
      });

      # Both install modules expose their wrapper as `wrappers.pi` in the
      # target configuration; `default` keeps the personal preset so existing
      # consumers of this flake keep their behavior.
      nixosModules = {
        pi = nix-wrapper-modules.lib.getInstallModule {
          name = "pi";
          value = wrapperModule;
        };
        personal = nix-wrapper-modules.lib.getInstallModule {
          name = "pi";
          value = personalWrapperModule;
        };
        default = self.nixosModules.personal;
      };

      homeModules = {
        pi = self.nixosModules.pi;
        personal = self.nixosModules.personal;
        camofoxBrowser = lib.modules.importApply ./profiles/home-camofox-browser.nix inputs;
        minimal = lib.modules.importApply ./profiles/home-minimal.nix inputs;
        default = self.homeModules.personal;
      };

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
