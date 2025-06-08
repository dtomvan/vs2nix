# vs2nix

Ports the 100 (could become more but I don't want to be a nuisance to the devs
simply because I want FODs) most popular (all-time downloads) Vintagestory mods
to nix. For use with the WIP [vintagestory nixos module](https://github.com/NixOS/nixpkgs/pull/414845).

As is that project, this one is very much a WIP. Don't use yet. Mod
dependencies aren't implemented (and might not exist in the top 100).

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
    packages.${system}.myModsDir = vs2nix.legacyPackages.${system}.makeModsDir "my-modpack-3000" (mods: with mods; [
      # run `nix flake show github:dtomvan/vs2nix` for the names
      primitivesurvival
      betterruins
      xskills
    ]);
  };
}
```

Then, one could run `vintagestory-server --addModPath $(nix build .#myModsDir)`.
In the future there will be support for `services.vintagestory.mods = [];`.


## Updating
Just `nix run`.
