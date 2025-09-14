{ self, ... }:
let
  default =
    _final: prev:
    let
      inherit (prev.stdenv.hostPlatform) system;
      doOverlay = builtins.hasAttr system self.legacyPackages;
      overlayContents =
        self.legacyPackages.${system}
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
