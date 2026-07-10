inputs:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.piProfiles.minimal;
  piMinimalWrapped =
    (inputs.self.wrappers.pi.extendModules {
      modules = [
        ./minimal.nix
        {
          binName = cfg.binName;
          pi.profileName = lib.mkForce cfg.profileName;
        }
      ];
    }).config.wrap
      { inherit pkgs; };
  piMinimalLauncher = pkgs.runCommand "${cfg.binName}-launcher-only" { } ''
    mkdir -p "$out/bin"
    ln -s "${piMinimalWrapped}/bin/${cfg.binName}" "$out/bin/${cfg.binName}"
  '';
in
{
  options.piProfiles.minimal = {
    enable = lib.mkEnableOption "standalone minimal Pi profile launcher";

    binName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "p-minimal";
      description = "Executable name for the standalone minimal Pi profile launcher.";
    };

    profileName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "minimal";
      description = "Mutable Pi profile name used by the minimal launcher.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ piMinimalLauncher ];
  };
}
