# pi-wrapped-module

Declarative Pi coding-agent setup packaged with `nix-wrapper-modules`.

## Run

```bash
nix run .#pi
```

The default app exposes a `p` binary.

## State

Runtime state is isolated from normal Pi and stored at:

```text
${XDG_STATE_HOME:-$HOME/.local/state}/pi-wrapped/default
```

The wrapper executable is named `p`. It sets:

- `PI_CODING_AGENT_DIR`
- `PI_PACKAGE_DIR`
- `PI_CODING_AGENT_SESSION_DIR`
- `PI_SKIP_VERSION_CHECK=1`
- `PI_TELEMETRY=0`

`settings.json` and `keybindings.json` are generated declaratively and
overwritten on every launch.

Default keybindings add Emacs-style `ctrl+p`/`ctrl+n` movement for the editor
and selectors, unbind conflicting model/session/provider actions, and move the
named-session filter toggle to `ctrl+shift+n`.

## Packages

Pi package-loader entries can still be written declaratively with `pi.packages`, but the default profile keeps that list empty and loads FFF from a Nix-built resource package instead:

- `pi-fff` from <https://github.com/dmtrKovalenko/fff>

Pi does not need to run `pi install` for default resources.

## Resources

Repo-managed resources live in:

- `skills/`
- `prompts/`
- `themes/`
- `extensions/`

These paths are written into generated Pi settings. Vendored resources currently include:

- extensions: `split-fork`, `todos`, `multi-edit`, `context`, `clanker-working-messages`, `explore`, `tree-summary-model`

`explore` and `tree-summary-model` now share cheap-model selection. Set:

- `PI_CHEAP_MODEL` for the primary cheap model
- `PI_CHEAP_FALLBACK_MODELS` for a comma-separated fallback list

Or configure them declaratively:

```nix
pi.cheapModels = {
  primary = "openai-codex/gpt-5.4-mini";
  fallbacks = [
    "github-copilot/gpt-5.4-mini"
    "anthropic/claude-haiku-4-5"
  ];
};
```

Feature-specific overrides still work:

- `PI_EXPLORE_MODEL`, `PI_EXPLORE_FALLBACK_MODELS`
- `PI_TREE_SUMMARY_MODEL`, `PI_TREE_SUMMARY_FALLBACK_MODELS`
- `PI_COMPACTION_MODEL`, `PI_COMPACTION_FALLBACK_MODELS`
- skills: `librarian`, `tmux`, `herdr`, `commit`, `github`
- themes: `gruvbox-dark-hard`

Nix-built Pi resource packages are also written into generated settings via `pi.resourcePackages`; the default profile exposes the `pi-fff` extension from the `.#pi-fff` package.

Matt Pocock skills are available from a pinned upstream source via `pi.mattPocockSkills`. The default profile exposes these manual-only skills by patching `disable-model-invocation: true` into their frontmatter:

- `skills/engineering/diagnosing-bugs`
- `skills/engineering/grill-with-docs`
- `skills/engineering/codebase-design`
- `skills/engineering/improve-codebase-architecture`
- `skills/engineering/domain-modeling`
- `skills/productivity/teach`

You can choose exactly which skill directories to expose, for example:

```nix
pi.mattPocockSkills = {
  enable = true;
  skills = [
    "skills/engineering/tdd"
    "skills/engineering/diagnosing-bugs"
    "skills/productivity/grilling"
  ];
  hiddenSkills = [
    "skills/engineering/diagnosing-bugs"
  ];
};
```

`hiddenSkills` patches the packaged `SKILL.md` frontmatter with `disable-model-invocation: true`, so those skills stay available as `/skill:...` commands without being advertised for automatic model invocation.

Herdr's Pi integration is also loaded declaratively by default from a pinned
Herdr source checkout. It reports Pi session and agent state to Herdr when Pi is
running inside Herdr, and stays inactive elsewhere. Disable with:

```nix
pi.herdrIntegration.enable = false;
```

The bundled `librarian` skill includes a checkout helper. The wrapper adds it to `PATH` for Pi-launched shell commands as both:

- `checkout.sh`
- `pi-librarian-checkout`

Use either command from any working directory, for example:

```bash
checkout.sh https://github.com/dmtrKovalenko/fff --path-only
```

## Package source

Pi is provided by `github:numtide/llm-agents.nix` as `llm-agents.packages.${system}.pi`.

## Thanks

Thanks to Armin Ronacher for the Pi extensions and skills in <https://github.com/mitsuhiko/agent-stuff>.
