{ pkgs, lib, fetchurl, makeWrapper, steam-run, appimage-run, ... }:

let
  version = "0.2.37";
  src = fetchurl {
    url = "https://github.com/horizon-rust/horizon/releases/download/launcher%400.2.37/horizon-launcher-linux-x86_64.AppImage";
    sha256 = "1n3fnav5v2jszjcf0xpwiyyj5675b01vahd7zq8vdk3mvc8adjk9";
  };
in
pkgs.stdenv.mkDerivation {
  pname = "horizon-launcher-appimage";
  inherit version src;

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ steam-run appimage-run ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/share/applications
    mkdir -p $out/share/horizon-launcher
    
    cp $src $out/share/horizon-launcher/horizon-launcher.AppImage
    chmod +x $out/share/horizon-launcher/horizon-launcher.AppImage
    
    cat > $out/bin/horizon-launcher << 'EOF'
#!/usr/bin/env bash
export PATH="$PATH"

# Check for Java 25
if command -v java >/dev/null 2>&1; then
  JAVA_VER=$(java -version 2>&1 | head -n 1 | grep -oP '"\K[0-9]+' || echo "0")
  if [ "$JAVA_VER" -ge 25 ] 2>/dev/null; then
    echo "Found Java $JAVA_VER"
  else
    echo "Java $JAVA_VER found but version < 25, using nix-shell for Java 25"
    exec ${pkgs.nix}/bin/nix-shell -p openjdk25 --run "steam-run ${pkgs.appimage-run}/bin/appimage-run $out/share/horizon-launcher/horizon-launcher.AppImage \"$@\""
    exit 0
  fi
else
  echo "Java not found, using nix-shell for Java 25"
  exec ${pkgs.nix}/bin/nix-shell -p openjdk25 --run "steam-run ${pkgs.appimage-run}/bin/appimage-run $out/share/horizon-launcher/horizon-launcher.AppImage \"$@\""
  exit 0
fi

# Use steam-run and appimage-run
if command -v steam-run >/dev/null 2>&1 && command -v appimage-run >/dev/null 2>&1; then
  exec steam-run appimage-run "$out/share/horizon-launcher/horizon-launcher.AppImage" "$@"
elif command -v appimage-run >/dev/null 2>&1; then
  exec appimage-run "$out/share/horizon-launcher/horizon-launcher.AppImage" "$@"
else
  exec "$out/share/horizon-launcher/horizon-launcher.AppImage" "$@"
fi
EOF
    chmod +x $out/bin/horizon-launcher
    
    runHook postInstall
  '';

  meta = with lib; {
    description = "Horizon Launcher (AppImage)";
    platforms = platforms.linux;
  };
}
