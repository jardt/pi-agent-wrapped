{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "pi-package-codex-goal";
  version = "0.1.34";

  src = fetchFromGitHub {
    owner = "fitchmultz";
    repo = "pi-codex-goal";
    rev = "3f35ae27341f27ddd946e9ce36e0a4eb2530cb95";
    hash = "sha256-cUWLBZ/Vy/ByJQBQuCe+adi/piS/UEKEVCFQsQWp+UQ=";
  };

  postPatch = ''
    substituteInPlace package-lock.json \
      --replace-fail \
        $'"resolved": "https://registry.npmjs.org/@earendil-works/pi-agent-core/-/pi-agent-core-0.80.3.tgz",\n      "dev": true,' \
        $'"resolved": "https://registry.npmjs.org/@earendil-works/pi-agent-core/-/pi-agent-core-0.80.3.tgz",\n      "integrity": "sha512-3qw0/GeRQBU/nlGjDe5Yb7ePKTmoxefx2YxyKMFAviFUMXpFexBG/hS7mBtwFahFvzrrTPPoRT6sFIDjwoDWPQ==",\n      "dev": true,' \
      --replace-fail \
        $'"resolved": "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-0.80.3.tgz",\n      "dev": true,' \
        $'"resolved": "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-0.80.3.tgz",\n      "integrity": "sha512-jPZLMeGL5kkMSEAwAklfXTMHqZvfhsJtCCpKGIr5Duk7mc0n4skjB1dugk7y0z3z8ZHIUCmPAWHdyDqgUz5vdA==",\n      "dev": true,' \
      --replace-fail \
        $'"resolved": "https://registry.npmjs.org/@earendil-works/pi-tui/-/pi-tui-0.80.3.tgz",\n      "dev": true,' \
        $'"resolved": "https://registry.npmjs.org/@earendil-works/pi-tui/-/pi-tui-0.80.3.tgz",\n      "integrity": "sha512-2BJI6qwRQfnM0Q7seL1+SbacU/jRRjBnN7Hu3n9BjAn7/s5FaBNnvdD1qBQYRsFTHfjqMaDsjYqanPyqwXj99w==",\n      "dev": true,'
  '';

  npmDepsHash = "sha256-K7zFnq1DEeGSEjFAZL9qZ8COTvWUDpErfqC/jxXI0mQ=";
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
