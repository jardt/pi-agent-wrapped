# Agent instructions

## Reference
<https://github.com/earendil-works/pi>
<https://github.com/BirdeeHub/nix-wrapper-modules>

## Pi-native child processes

`PI_LAUNCHER_BIN` is the authoritative identity of the currently active Pi wrapper. Pi-native features that fork, resume, or create a child of the active Pi session must reuse this exact launcher. This includes split/fork, explore, and similar extension-managed child sessions.

Do not resolve a profile name from `PATH` or fall back to `process.execPath` for these Pi-native descendants. If `PI_LAUNCHER_BIN` is unavailable, fail instead of guessing.

This invariant does not apply to root launchers, generic orchestrators, configured commands, arbitrary shell commands, or explicit profile selection. Those may run any command selected by their user or configuration.

`run-current-pi` is an optional convenience for manually re-executing the active wrapper.

Examples:

```sh
run-current-pi
run-current-pi --session /path/to/session.jsonl
herdr pane run "$PANE" "run-current-pi --session '/path/to/session.jsonl'"
```

## Generic package boundary

This repository is a generic public Pi wrapper. Keep all defaults neutral: no personal models, themes, keybindings, skills, prompts, named profiles, endpoints, secrets, or third-party integrations enabled by default.

Reusable capabilities belong here: wrapper options, package builders, bundled resources, integrations, `lib.mkProfile`, and the generic multi-profile Home Manager module. Concrete profiles and personal presets belong in the consumer repository.

All default flake aliases must remain generic. Neutral examples and test fixtures are allowed, but do not export them as opinionated named profiles.

## Pi profile packaging model

Profiles must be independently evaluated and installable. `lib.mkProfile` is the package boundary: it accepts downstream wrapper modules and produces a launcher-only package so multiple profiles do not collide on Pi's underlying binaries.

`homeModules.pi` maps arbitrary `programs.piWrapped.profiles` entries through that factory. Keep the profile option generic; use deferred wrapper modules instead of duplicating the `pi.*` option schema in the Home Manager module.

Profiles may expose aliases, but launcher names and mutable `profileName` values must be unique. An optional profile must never mutate or replace another profile.

Example consumer shape:

```nix
imports = [ inputs.pi-agent-wrapped.homeModules.pi ];

programs.piWrapped = {
  enable = true;
  sharedModules = [ ./pi/base.nix ];
  profiles.main = {
    profileName = "default";
    binName = "p";
    aliases = [ "pi" ];
    modules = [ ./pi/main.nix ];
  };
};
```
