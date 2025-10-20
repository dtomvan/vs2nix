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
            pkgs.writers.writeNuBin mainProgram
              # nu
              ''
                # let developers know it's me, so they can find me if they don't like what I'm
                # doing or have inquiries
                let headers = [
                    User-Agent
                    "github.com/dtomvan/vs2nix"
                ]

                # more or less 10k downloads or more
                let num_mods = 500

                # HACK: idk if this is the right way to do fallbacks in nu
                http get --headers $headers "https://mods.vintagestory.at/api/mods?orderby=downloads"
                    | get mods
                    | take $num_mods
                    | par-each { |mod| http get --headers $headers $'https://mods.vintagestory.at/api/mod/($mod.modid)' }
                    | where { |mod| $mod.mod?.releases?.0?.modidstr? != null }
                    | each { |mod| $mod.mod }
                    | each { |mod| try {
                        # The API does not expose something like
                        # `isPrerelease`, but this seems to be sorta the way
                        # the frontend handles it anyways
                        let latest = $mod.releases? 
                          | where modversion? != null
                          | where not ($it.modversion | str contains pre) 
                          | where not ($it.modversion | str contains rc)
                          | first
                        let url = $latest.mainfile? | url parse | reject query params | url join 

                        {
                            pname: $latest.modidstr,
                            version: $latest.modversion,
                            description: $mod.name?,
                            url: $url,
                            hash: (
                                nix store prefetch-file --json $url
                                  # sanitize the name somewhat to hopefully avoid more errors
                                  --name $'($latest.modidstr)-($latest.modversion).zip'
                                | from json
                                | get hash
                            )
                        } 
                    } catch { null } }
                    | where { |mod| $mod != null }
                    | sort-by pname
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
