# Maintenance

## Pi package

This repo packages Pi directly instead of consuming `numtide/llm-agents.nix` for Pi.

Policy: package the latest upstream `main` commit, not the latest npm release. The npm release can lag behind Pi `main`.

Files:

- `packages/pi/package.nix` — Nix source-build package for the Pi monorepo.
- `packages/pi/default.nix` — small `callPackage` entrypoint.
- `packages/pi/hashes.json` — pinned upstream `main` commit, display version, source hash, and npm dependency hash.
- `packages/pi/generated/` — checked-in generated AI model catalogs used to keep the Nix build network-free.

Consumers in this repo:

- `flake.nix` exposes `packages.${system}.pi` from `./packages/pi`.
- `packages/pi-resources.nix` receives that local Pi package.
- `module.nix` defaults `config.package` to `pkgs.callPackage ./packages/pi { }`.

## Updating Pi to latest main

Always refresh the upstream checkout first:

```sh
# via librarian skill/tool, or equivalent git fetch
# repo: earendil-works/pi
```

Then get the commit and version:

```sh
git -C ~/.cache/checkouts/github.com/earendil-works/pi rev-parse HEAD
git -C ~/.cache/checkouts/github.com/earendil-works/pi describe --tags --always --dirty
jq -r .version ~/.cache/checkouts/github.com/earendil-works/pi/packages/coding-agent/package.json
```

Update `packages/pi/hashes.json`:

```json
{
  "version": "X.Y.Z-main-<shortrev>",
  "rev": "<full upstream main commit>",
  "sourceHash": "sha256-...",
  "npmDepsHash": "sha256-..."
}
```

### 1. Update source hash

Calculate the source hash from the exact commit:

```sh
rev=<full upstream main commit>
nix hash convert --hash-algo sha256 --to sri \
  "$(nix-prefetch-url --unpack https://github.com/earendil-works/pi/archive/$rev.tar.gz)"
```

Copy the result into `sourceHash`.

### 2. Refresh generated model catalogs

The Pi monorepo build generates provider model catalogs by fetching network APIs. Nix builds must not do that, so generate them outside Nix and commit them under `packages/pi/generated/`.

```sh
cd ~/.cache/checkouts/github.com/earendil-works/pi
npm --userconfig /dev/null install --ignore-scripts
cd packages/ai
npm --userconfig /dev/null run generate-models
npm --userconfig /dev/null run generate-image-models
```

Copy generated files into this repo:

```sh
rm -rf packages/pi/generated
mkdir -p packages/pi/generated/providers
cp ~/.cache/checkouts/github.com/earendil-works/pi/packages/ai/src/providers/*.models.ts packages/pi/generated/providers/
cp ~/.cache/checkouts/github.com/earendil-works/pi/packages/ai/src/models.generated.ts packages/pi/generated/
cp ~/.cache/checkouts/github.com/earendil-works/pi/packages/ai/src/image-models.generated.ts packages/pi/generated/
```

### 3. Update npm dependency hash

Set a dummy dependency hash:

```json
"npmDepsHash": "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
```

Build:

```sh
nix build .#pi --no-link --builders ''
```

Nix will fail with the expected `npmDepsHash`. Copy the `got:` hash into `packages/pi/hashes.json`.

### 4. Validate

```sh
nix fmt
nix build .#pi --no-link --builders ''
nix build .#p --no-link --builders ''
```

`--builders ''` is useful because remote builders can hang or be slow for this source build.

## Source-build notes

- Latest `main` may not be published to npm yet. Do not depend on the npm tarball for Pi itself.
- `packages/pi/package.nix` builds the monorepo from GitHub source.
- Generated model catalogs are patched into `packages/ai/src` during `postPatch`.
- The build patches scripts from `tsgo` to `tsc` and raises TypeScript target/lib to `ES2024` for Nix compatibility.
- `npmRebuildFlags = [ "--ignore-scripts" ]` avoids native rebuild issues during the offline npm setup phase.
- `packages/pi-resources.nix` warns instead of failing on extension devDependency Pi-version mismatch when the Pi package is a source-built main commit (`piPackage.rev` exists).
- Do not reintroduce the `llm-agents` flake input just for Pi updates.
