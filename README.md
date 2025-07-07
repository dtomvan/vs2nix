# vs2nix

Ports the 400 (could become more but I don't want to be a nuisance to the devs
simply because I want FODs) most popular (all-time downloads) Vintagestory mods
to nix. Also includes latest vintagestory stable and pre-releases, along with
[Rustique](https://github.com/Tekunogosu/Rustique), a mod manager for Vintagestory.

This project is very much a WIP. Don't use yet. Mod dependencies aren't
implemented (and might not exist in the top 400).

Also, if you do dare to use this, expect to read this repo's source code.
I haven't documented, say, the nixos module at all yet.

> [!WARNING]
> **DISCLAIMER**
>
> If your mod is low in the top 400, it might get _pushed out on the next
> update_. This is intended because I don't plan on adding the entire catalogue
> anytime soon. That would require finding some way to only update certain mods
> when needed, whereas currently I do it "all at once". See for the
> implementation of the updater `parts/updater.nix`.

## Usage

In a flake:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    vs2nix = {
      url = "github:dtomvan/vs2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, vs2nix }: let
    system = "x86_64-linux";
  in {
    packages.${system}.myModsDir = vs2nix.legacyPackages.${system}.makeVintageStoryModsDir "my-modpack-3000" (mods: with mods; [
      # run `nix flake show github:dtomvan/vs2nix` for the names
      primitivesurvival
      betterruins
      xskills
    ]);
  };
}
```

Then, one could run `vintagestory-server --addModPath $(nix build .#myModsDir)`.

For NixOS, you should import `vs2nix.nixosModules.default` and then you can set something like:

```nix
let
  host = "127.0.0.1";
  port = 42420;
in
{
  services.vintagestory = {
    enable = true;
    inherit host port;
    extraFlags = [
      "--addModPath"
      (builtins.toString (inputs.vs2nix.legacyPackages.x86_64-linux.makeVintageStoryModsDir "my-mods" (mods: with mods; [
        primitivesurvival
        carryon
        xskills
      ])))
    ];
  };
}
```

You can then access the admin console with `vintagestory-admin`.

## `vintagestory` and `vintagestory-beta` package

I've added two new packages, in order to use the latest prerelease version of
Vintagestory easily. Also I'll try to push `vintagestory` updates ASAP whereas
they'd need a relatively lengthy review process in order to get pushed into the
central `nixpkgs` repo.

Just `nix run github:dtomvan/vs2nix#vintagestory-beta` to try the beta (back up
your savefiles!). You can't have both installed at the same time due to file
collisions as of now.

### Installing Vintagestory/Rustique from this repo on NixOS
If you've imported the flake as an input like above, you can add an overlay:

```nix
outputs = { nixpkgs, vs2nix, ... }: let
  pkgs = import nixpkgs {
    overlays = [
      vs2nix.overlay # or .overlays.default or .overlays.vs2nix
    ];
    config = {
      allowUnfree = true;
    };
  };
in {
  nixosConfigurations.alice = nixpkgs.lib.nixosSystem {
    inherit pkgs;
    modules = [
      ({ pkgs, ... }: { environment.systemPackages = with pkgs; [ vintagestory-beta rustique ]; })
      ./configuration.nix
    ];
  };
};
```

## Updating mods
Just `nix run`.
