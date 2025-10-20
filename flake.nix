{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
