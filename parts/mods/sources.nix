{
  perSystem =
    { pkgs, ... }:
    let
      inherit (pkgs) lib;
      sources = lib.pipe ../../sources.json [
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
        vintagestoryMods = sources;
        # usage: makeVintageStoryModsDir "my-modpack" (mods: with mods; [ carryon medievalexpansion spyglass ])
        makeVintageStoryModsDir = name: f: pkgs.linkFarmFromDrvs name (f sources);
      };
    };
}
