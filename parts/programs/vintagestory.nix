# version to keep more up-to-date maybe (nixpkgs PRs aren't really addressed
# yet by any committer)
{
  perSystem =
    { pkgs, ... }:
    {
      packages = import ../../misc/vintagestory-overlay.nix { inherit pkgs; };
    };
}
