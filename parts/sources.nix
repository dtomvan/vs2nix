{
  perSystem =
    { pkgs, ... }:
    let
      inherit (pkgs) lib;
      sources = lib.pipe ../sources.json [
        lib.importJSON
        (lib.map (
          source:
          lib.nameValuePair source.pname (
            pkgs.fetchurl {
              inherit (source) pname version url hash;
              meta = { inherit (source) description; };
            }
          )
        ))
        lib.listToAttrs
      ];
    in
    {
      packages = sources;

      legacyPackages = {
        mods = sources;
        allMods = pkgs.linkFarmFromDrvs "all-vintagestory-mods" (lib.attrValues sources);
        # usage: makeModsDir "my-modpack" (mods: with mods; [ carryon medievalexpansion spyglass ])
        makeModsDir = name: f: pkgs.linkFarmFromDrvs name (f sources);
      };
    };
}
