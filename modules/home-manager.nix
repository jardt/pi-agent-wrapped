inputs:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.piWrapped;
  launcherNameType = lib.types.strMatching "[A-Za-z0-9][A-Za-z0-9._+-]*";
  profileNameType = lib.types.strMatching "[A-Za-z0-9][A-Za-z0-9._-]*";
  profileType = lib.types.submodule (
    { name, ... }:
    {
      options = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to install this Pi profile's launchers.";
        };

        profileName = lib.mkOption {
          type = profileNameType;
          default = name;
          description = "Name of the isolated mutable Pi state profile.";
        };

        binName = lib.mkOption {
          type = launcherNameType;
          default = "p-${name}";
          description = "Primary executable name for this Pi profile.";
        };

        aliases = lib.mkOption {
          type = lib.types.listOf launcherNameType;
          default = [ ];
          description = "Additional executable names that launch this same Pi profile.";
        };

        modules = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
          default = [ ];
          description = "Wrapper modules applied after programs.piWrapped.sharedModules.";
        };
      };
    }
  );
  enabledProfiles = lib.filterAttrs (_: profile: profile.enable) cfg.profiles;
  enabledProfileValues = builtins.attrValues enabledProfiles;
  launcherNames = lib.concatMap (
    profile: [ profile.binName ] ++ profile.aliases
  ) enabledProfileValues;
  profileNames = map (profile: profile.profileName) enabledProfileValues;
in
{
  options.programs.piWrapped = {
    enable = lib.mkEnableOption "declarative Pi profile launchers";

    sharedModules = lib.mkOption {
      type = lib.types.listOf lib.types.deferredModule;
      default = [ ];
      description = "Wrapper modules applied to every enabled Pi profile before profile-specific modules.";
    };

    profiles = lib.mkOption {
      type = lib.types.attrsOf profileType;
      default = { };
      description = "Independently evaluated Pi wrapper profiles.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = builtins.length launcherNames == builtins.length (lib.unique launcherNames);
        message = "programs.piWrapped profile binName and alias values must be globally unique";
      }
      {
        assertion = builtins.length profileNames == builtins.length (lib.unique profileNames);
        message = "programs.piWrapped enabled profiles must use unique profileName values";
      }
    ];

    home.packages = lib.mapAttrsToList (
      _: profile:
      inputs.self.lib.mkProfile {
        inherit pkgs;
        inherit (profile) profileName binName aliases;
        modules = cfg.sharedModules ++ profile.modules;
      }
    ) enabledProfiles;
  };
}
