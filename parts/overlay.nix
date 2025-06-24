{ self, ... }:
let
  default =
    _final: prev:
    let
      inherit (prev.stdenv.hostPlatform) system;
      doOverlay = builtins.hasAttr system self.legacyPackages;
      overlayContents =
        self.legacyPackages.${system}
        # vintagestory is unfree, need to pass it like this so that `nixpkgs.config.allowUnfree` gets respected
        // (import ../misc/vintagestory-overlay.nix { pkgs = prev; })
        // {
          inherit (self.packages.${system}) rustique;
        };
    in
    prev.lib.optionalAttrs doOverlay overlayContents;
in
{
  flake = {
    overlays = {
      inherit default;
      vs2nix = default;
    };
    overlay = default;
  };
}
