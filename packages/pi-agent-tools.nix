{
  lib,
  makeWrapper,
  runCommand,
  coreutils,
  git,
}:

runCommand "pi-agent-tools" { nativeBuildInputs = [ makeWrapper ]; } ''
  mkdir -p $out/bin
  cp ${../skills/librarian/checkout.sh} $out/bin/pi-librarian-checkout
  chmod +x $out/bin/pi-librarian-checkout
  cp ${../scripts/run-current-pi} $out/bin/run-current-pi
  substituteInPlace $out/bin/run-current-pi \
    --replace-fail '@readlink@' '${coreutils}/bin/readlink'
  chmod +x $out/bin/run-current-pi
  makeWrapper $out/bin/pi-librarian-checkout $out/bin/checkout.sh \
    --prefix PATH : ${
      lib.makeBinPath [
        coreutils
        git
      ]
    }
''
