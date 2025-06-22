# version to keep more up-to-date maybe (nixpkgs PRs aren't really addressed
# yet by any committer)
{
  perSystem =
    { pkgs, ... }:
    {
      packages.default = pkgs.vintagestory.overrideAttrs (
        final: prev: {
          version = "1.20.12";

          src = pkgs.fetchzip {
            url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${final.version}.tar.gz";
            hash = "sha256-GlxBpnQBk1yZfh/uPK83ODrwn/VoORA3gGkvcXy+nV8=";
          };
        }
      );
    };
}
