inputs:
{
  config,
  lib,
  pkgs,
  wlib,
  ...
}:
let
  jsonFmtType = wlib.types.structuredValueWith { typeName = "JSON"; };
  resourceDirs = {
    skills = ./skills;
    prompts = ./prompts;
    themes = ./themes;
    extensions = ./extensions;
  };
in
{
  imports = [ wlib.modules.default ];

  options.pi = {
    profileName = lib.mkOption {
      type = lib.types.nonEmptyStr;
      default = "default";
      description = "Name used for the isolated mutable Pi profile directory.";
    };

    stateRoot = lib.mkOption {
      type = lib.types.str;
      default = "\${XDG_STATE_HOME:-$HOME/.local/state}/pi-wrapped";
      description = "Shell expression for the root directory containing Pi wrapper profiles.";
    };

    settings = lib.mkOption {
      type = jsonFmtType;
      default = { };
      description = "Extra declarative Pi settings merged into generated settings.json.";
    };
  };

  config = {
    package = lib.mkDefault inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi;
    binName = lib.mkDefault "pi";

    envDefault = {
      PI_SKIP_VERSION_CHECK = "1";
      PI_TELEMETRY = "0";
    };

    constructFiles.generatedSettings = {
      relPath = "share/pi-wrapped/settings.json";
      content = builtins.toJSON (
        {
          defaultProjectTrust = "ask";
          enableInstallTelemetry = false;
          packages = [ ];
          skills = [ resourceDirs.skills ];
          prompts = [ resourceDirs.prompts ];
          themes = [ resourceDirs.themes ];
          extensions = [ resourceDirs.extensions ];
        }
        // config.pi.settings
      );
    };

    runShell = [
      ''
        profile_dir="${config.pi.stateRoot}/${config.pi.profileName}"
        mkdir -p "$profile_dir" "$profile_dir/packages" "$profile_dir/sessions"
        cp ${config.constructFiles.generatedSettings.path} "$profile_dir/settings.json"
        export PI_CODING_AGENT_DIR="$profile_dir"
        export PI_PACKAGE_DIR="$profile_dir/packages"
        export PI_CODING_AGENT_SESSION_DIR="$profile_dir/sessions"
      ''
    ];
  };
}
