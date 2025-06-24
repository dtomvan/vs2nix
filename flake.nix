{
  inputs = {
    nixpkgs.url = "github:numtide/nixpkgs-unfree/nixos-unstable";
    import-tree.url = "github:vic/import-tree";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      import-tree,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (import-tree ./parts);
}
