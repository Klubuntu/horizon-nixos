{ pkgs, lib, fetchurl, steam-run, makeWrapper, ... }:

let
  version = "0.2.37";
  src = fetchurl {
    url = "https://github.com/horizon-rust/horizon/releases/download/launcher%400.2.37/horizon-launcher-linux-x86_64.tar.gz";
    sha256 = "1zhvnf2f10cky125varhllmhn134f8zvsnpyks8y1345rjnh9jzi";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "horizon-launcher";
  inherit version src;

  nativeBuildInputs = [ makeWrapper ];

  unpackPhase = ''
    tar -xzf $src
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/libexec
    
    cp horizon-launcher $out/libexec/horizon-launcher
    chmod +x $out/libexec/horizon-launcher
    # makeWrapper creates the bin script
    chmod +x $out/bin/horizon-launcher 2>/dev/null || true
    
    cat > $out/bin/horizon-launcher << 'WRAPPER'
#!/usr/bin/env bash
LAUNCHER="@out@/libexec/horizon-launcher"

# Check Java version
if command -v java >/dev/null 2>&1; then
  JAVA_VER=$(java -version 2>&1 | head -n 1 | grep -oP '"\K[0-9]+' | head -n 1)
  if [ -n "$JAVA_VER" ] && [ "$JAVA_VER" -ge 25 ] 2>/dev/null; then
    exec @steamRun@/bin/steam-run "$LAUNCHER" "$@"
  fi
fi

# Need Java 25
exec @nix@/bin/nix-shell -p openjdk25 --run "@steamRun@/bin/steam-run '$LAUNCHER' \"\$@\""
WRAPPER
    substituteInPlace $out/bin/horizon-launcher \
      --subst-var out \
      --subst-var-by steamRun ${steam-run} \
      --subst-var-by nix ${pkgs.nix}
    chmod 755 $out/bin/horizon-launcher
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Horizon Launcher";
    platforms = platforms.linux;
    mainProgram = "horizon-launcher";
  };
}
