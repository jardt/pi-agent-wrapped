inputs:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.piProfiles.camofoxBrowser;
  piCamofoxWrapped =
    (inputs.self.wrappers.personal.extendModules {
      modules = [
        ./camofox-browser.nix
        {
          binName = cfg.binName;
          pi = {
            profileName = lib.mkForce cfg.profileName;
            camofoxBrowser = {
              url = lib.mkForce cfg.url;
              apiKeyFile = cfg.apiKeyFile;
            };
          };
        }
      ];
    }).config.wrap
      { inherit pkgs; };
  piCamofoxLauncher = pkgs.runCommand "${cfg.binName}-launcher-only" { } ''
    mkdir -p "$out/bin"
    ln -s "${piCamofoxWrapped}/bin/${cfg.binName}" "$out/bin/${cfg.binName}"
  '';
in
{
  options.piProfiles.camofoxBrowser = {
    enable = lib.mkEnableOption "standalone Pi Camofox browser profile launcher";

    binName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "p-camofox";
      description = "Executable name for the standalone Camofox Pi profile launcher.";
    };

    profileName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "pi-camofox";
      description = "Mutable Pi profile name used by the Camofox launcher.";
    };

    url = lib.mkOption {
      type = lib.types.str;
      default = "http://localhost:9377";
      description = "Camofox Browser REST API base URL.";
    };

    apiKeyFile = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional file containing the Camofox Browser API key.";
    };

  };

  config = lib.mkIf cfg.enable {
    home.packages = [ piCamofoxLauncher ];
  };
}
