{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "pi-package-codex-goal";
  version = "0.1.37";

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-codex-goal";
    rev = "888610bc85d0b275b516ec870793514851449afa";
    hash = "sha256-eH4eEzyXPpsvhAtwjQlHpdtf5UXN1J55ySAwKOR5fmg=";
  };

  postPatch = ''
    substituteInPlace package-lock.json \
      --replace-fail \
        $'"resolved": "https://registry.npmjs.org/@earendil-works/pi-agent-core/-/pi-agent-core-0.80.9.tgz",\n      "dev": true,' \
        $'"resolved": "https://registry.npmjs.org/@earendil-works/pi-agent-core/-/pi-agent-core-0.80.9.tgz",\n      "integrity": "sha512-tObjeOLiw1kYUciBi9R+rRyc4QGK+1akbLLQHvzsn2JrrV2btUdDncJ7jMIR5TKvOYKzKxAwQSl/5k7h3Tjrrg==",\n      "dev": true,' \
      --replace-fail \
        $'"resolved": "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-0.80.9.tgz",\n      "dev": true,' \
        $'"resolved": "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-0.80.9.tgz",\n      "integrity": "sha512-kHsH5nO4FU7mbKnskK0BVPVuWzNb2DrZtiN1fb6LamP+6BMI8xEZiAOw2fqs4VudvlMQgOLjtbgErv+kNJRPIg==",\n      "dev": true,' \
      --replace-fail \
        $'"resolved": "https://registry.npmjs.org/@earendil-works/pi-tui/-/pi-tui-0.80.9.tgz",\n      "dev": true,' \
        $'"resolved": "https://registry.npmjs.org/@earendil-works/pi-tui/-/pi-tui-0.80.9.tgz",\n      "integrity": "sha512-unPTW8hRgIHEGjV8mJJ2jqm+fzgnRubes6V2FPk9ay1W9ZLofcpYQ3NDfrODXSci+oKbBpX9JyYUMfQV6jCA/A==",\n      "dev": true,'
  '';

  npmDepsHash = "sha256-dfktAlxLHOxB7gCqx/YyrKr/ewOewdtxiKxt+4Hmp04=";
  npmDepsFetcherVersion = 2;

  buildPhase = ''
    runHook preBuild
    npm run typecheck
    npm test
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    package_dir="$out/share/pi-packages/codex-goal"
    mkdir -p "$package_dir"
    cp package.json README.md CHANGELOG.md LICENSE "$package_dir/"
    cp -R src prompts "$package_dir/"

    runHook postInstall
  '';

  meta = {
    description = "Codex-style goal tracking and continuation for Pi";
    homepage = "https://github.com/fitchmultz/pi-codex-goal";
    license = lib.licenses.mit;
  };
}
