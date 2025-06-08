{
  perSystem =
    { pkgs, ... }:
    {
      apps.default =
        let
          mainProgram = "update-vs2nix.sh";
        in
        {
          type = "app";
          program =
            pkgs.writeNuBin mainProgram
              # nu
              ''
                # let developers know it's me, so they can find me if they don't like what I'm
                # doing or have inquiries
                let headers = [
                    User-Agent
                    "github.com/dtomvan/vs2nix"
                ]

                # more or less 10k downloads or more
                let num_mods = 400

                # HACK: idk if this is the right way to do fallbacks in nu
                http get --headers $headers "https://mods.vintagestory.at/api/mods?orderby=downloads"
                    | get mods
                    | take $num_mods
                    | par-each { |mod| http get --headers $headers $'https://mods.vintagestory.at/api/mod/($mod.modid)' }
                    | filter { |mod| $mod.mod?.releases?.0? != null }
                    | each { |mod| $mod.mod }
                    | each { |mod| try { {
                        name: $mod.releases?.0?.filename?,
                        id: $mod.releases?.0?.modidstr,
                        description: $mod.name?,
                        url: $mod.releases?.0?.mainfile?,
                        hash: (
                            nix store prefetch-file --json $mod.releases?.0?.mainfile?
                            | from json
                            | get hash
                        )
                    } } catch { null } }
                    | filter { |mod| $mod != null }
                    | sort-by name
                    | to json
                    | save --force $'(pwd)/sources.json'
              '';
          meta = {
            inherit mainProgram;
            description = "Update sources.json (downloads ~600 MB across 400 mods)";
          };
        };
    };
}
