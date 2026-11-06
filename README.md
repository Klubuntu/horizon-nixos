# Horizon Launcher Nix Flake

This flake provides packages for Horizon Launcher.

## Usage

### Run directly
```bash
nix run github:your-username/horizon-nixos  # or from local
nix run .#horizon-launcher-tar
nix run .#horizon-launcher-appimage
```

### Install to profile
```bash
nix profile install .#horizon-launcher-tar
```

### In NixOS configuration
```nix
{
  inputs.horizon-launcher.url = "path:/home/coder/Documents/flakes/horizon-nixos";
  
  environment.systemPackages = [ inputs.horizon-launcher.packages.${pkgs.system}.horizon-launcher-tar ];
}
```

## Features
- Downloads Horizon Launcher v0.2.37 from official GitHub releases
- Uses `steam-run` for running
- Automatically detects Java version - if Java 25+ is available, uses it
- If Java < 25 or not found, uses `nix-shell -p openjdk25` to provide Java 25
- Supports both tar.gz and AppImage versions
