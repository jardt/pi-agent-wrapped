# pi-wrapped-module

Declarative [Pi](https://github.com/earendil-works/pi) coding-agent setup packaged with
[`nix-wrapper-modules`](https://github.com/BirdeeHub/nix-wrapper-modules).

The repo has two layers:

- **Generic module** (`module.nix`, exposed as `wrapperModules.pi`): a
  wrapper module with neutral defaults. It provides simple `pi.*` options for
  models, theme, keybindings, skills, extensions, prompts, and optional
  third-party integrations — all off/empty by default.
- **Personal preset** (`presets/personal.nix`, exposed as
  `wrapperModules.personal`): my predefined Pi configuration layered on the
  generic module with `lib.mkDefault`. The `p*` packages/apps and the profile
  home modules are built from this layer.

## Which output should I consume?

| Output | Layer | Use when |
| --- | --- | --- |
| `wrapperModules.pi`, `wrappers.pi`, `nixosModules.pi`, `homeModules.pi` | generic | You want a clean Pi wrapper and your own configuration |
| `wrapperModules.personal`, `wrappers.personal`, `nixosModules.personal`, `homeModules.personal` | personal | You want the author's predefined setup |
| every `default` alias, `packages.p*`, `apps.*`, `homeModules.minimal`, `homeModules.camofoxBrowser` | personal | Same — `default` always means the personal preset |

If you are not the author, consume the `pi` outputs. The generic module ships
**neutral defaults**: no default model, theme, keybindings, skills, or
extensions, and every integration disabled. Anything you don't set is omitted
from the generated `settings.json`, so plain Pi behavior applies. Do not use
`default`/`personal` outputs unless you explicitly want the personal
configuration (specific OpenAI Codex models, gruvbox theme, Herdr integration,
extra skills, and so on).

### Build your own profile on the generic module

Set options directly at `wrap` time:

```nix
inputs.pi-agent-wrapped.wrappers.pi.wrap {
  inherit pkgs;
  pi.defaultModel = "anthropic/claude-sonnet-5";
}
```

Or keep a reusable profile module and extend the generic wrapper with it —
this is exactly how the bundled personal preset and profiles are built:

```nix
# my-pi-profile.nix
{
  binName = "my-pi";
  pi = {
    profileName = "my-pi";
    defaultModel = "anthropic/claude-sonnet-5";
    theme = "dark";
    localSkills = [ "commit" "github" ];
    bundledExtensions = [ "context" "multi-edit" ];
    fff.enable = true;
  };
}
```

```nix
myPi =
  (inputs.pi-agent-wrapped.wrappers.pi.extendModules {
    modules = [ ./my-pi-profile.nix ];
  }).config.wrap
    { inherit pkgs; };
```

You can also re-export your extended module from your own flake as a
`wrapperModules.*` output, the same way this flake exports `personal`.

## Run (personal packages)

```bash
nix run .#p
```

Available flake outputs:

- `.#p`: personal wrapper package exposing only `bin/p`
- `.#p-minimal`: personal minimal profile exposing only `bin/p-minimal`
- `.#pi-wrapped`: full wrapped personal Pi package
- `.#pi`: unwrapped source-built Pi

Use `.#p` when you want the wrapped launcher without colliding with another Pi
package that already provides `bin/pi`.

## Use the generic module

As a standalone package:

```nix
inputs.pi-agent-wrapped.wrappers.pi.wrap {
  inherit pkgs;
  pi = {
    defaultModel = "anthropic/claude-sonnet-5";
    theme = "dark";
    localSkills = [ "commit" "github" ];
    bundledExtensions = [ "context" "multi-edit" ];
    fff.enable = true;
  };
}
```

Via NixOS / home-manager / nix-darwin (installs only the launcher binary):

```nix
# generic
imports = [ inputs.pi-agent-wrapped.homeModules.pi ];
# or the personal preset
imports = [ inputs.pi-agent-wrapped.homeModules.personal ];

wrappers.pi.enable = true;
wrappers.pi.pi.defaultModel = "anthropic/claude-sonnet-5";
```

Selected `pi.*` options (all optional; unset keys are omitted from the
generated `settings.json` so Pi's own defaults apply):

- `pi.defaultModel`: fully-qualified `provider/model` id, split into
  `defaultProvider`/`defaultModel`
- `pi.enabledModels`: model allowlist
- `pi.defaultThinkingLevel`: `off`..`xhigh`
- `pi.theme`, `pi.keybindings`, `pi.settings` (free-form extra settings;
  generated keys are reserved)
- `pi.projectTrust`: written as `defaultProjectTrust` (default `"ask"`)
- `pi.profileName`, `pi.stateRoot`: mutable profile isolation
- `pi.localSkills`, `pi.bundledExtensions`: repo-bundled skills/extensions
- `pi.resourcePackages`, `pi.packages`: Nix-built and runtime Pi packages
- `pi.appendSystemPrompt` / `pi.overrideSystemPrompt`: profile-local
  `APPEND_SYSTEM.md`
- `pi.splash.*`: launch splash text
- Integrations, each opt-in: `pi.fff`, `pi.dynamicWorkflows`, `pi.goal`,
  `pi.herdrIntegration`, `pi.mattPocockSkills`
  (note: its default skill list uses import-from-derivation),
  `pi.camofoxBrowser`, `pi.gondolin`, `pi.cheapModels`, `pi.librarian.mode`

## Personal profiles

Home-manager modules for standalone profile launchers built on the personal
preset:

```nix
imports = [
  inputs.pi-agent-wrapped.homeModules.minimal
  inputs.pi-agent-wrapped.homeModules.camofoxBrowser
];

piProfiles.minimal.enable = true;        # bin/p-minimal
piProfiles.camofoxBrowser.enable = true; # bin/p-camofox
```

## State

Runtime state is isolated from normal Pi and stored at:

```text
${XDG_STATE_HOME:-$HOME/.local/state}/pi-wrapped/<profileName>
```

The default wrapper executable is named `p`. It sets:

- `PI_LAUNCHER_BIN` to the canonical immutable path of the currently running wrapper binary; child Pi processes must reuse this exact launcher
- `PI_CODING_AGENT_DIR`
- `PI_PACKAGE_DIR`
- `PI_CODING_AGENT_SESSION_DIR`
- `PI_SKIP_VERSION_CHECK=1`
- `PI_TELEMETRY=0`

Each profile also gets its own generated `AGENTS.md` inside `PI_CODING_AGENT_DIR`, so profile-specific agent instructions follow the active wrapped launcher. `run-current-pi` fails closed unless `PI_LAUNCHER_BIN` is an absolute, canonical, executable file.

Each profile also gets a generated `APPEND_SYSTEM.md` inside `PI_CODING_AGENT_DIR` to append wrapper-specific response-style instructions without replacing Pi's default system prompt.

`settings.json` and `keybindings.json` are generated declaratively and
overwritten on every launch.

Example append:

```nix
pi.appendSystemPrompt = ''
  # Local rules

  Always mention exact Nix option names when relevant.
'';
```

Example override:

```nix
pi.overrideSystemPrompt = ''
  # Response style

  Answer in one sentence unless asked otherwise.
'';
```

Example splash override:

```nix
pi.splash = {
  logoText = ''
    ██████╗ ██╗
    ██╔══██╗██║
    ██████╔╝██║
    ██╔═══╝ ██║
    ██║     ██║
    ╚═╝     ╚═╝
  '';
  versionText = null;
  compactHelpText = "Press {expandKey} for help.";
  helpText = "Pi profile. Wrapped launcher only.";
};
```
