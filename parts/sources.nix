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
              inherit (source) url hash;
              # append .zip so VS can recognize it
              name = "${source.pname}-${source.version}.zip";
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
