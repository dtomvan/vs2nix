{
  perSystem =
    { pkgs, ... }:
    {
      apps.update-report =
        let
          mainProgram = "update-report.sh";
        in
        {
          type = "app";
          program =
            pkgs.writers.writeNuBin mainProgram
              # nu
              ''
                # from https://gist.github.com/nome/8ec70fa3cfe3b2a1bf575c9339a4b9b3
                export def difference [a: list<any>, b: list<any>]: nothing -> list<any> {
                  $a | filter {|x| $x not-in $b }
                }

                # this is hacky because IDK nu idioms

                let oldfile = git cat-file -p (git ls-tree HEAD sources.json | awk '{ print $3 }') 
                    | from json
                    | select pname version
                let newfile = open sources.json | select pname version

                let oldnames = $oldfile | select pname
                let newnames = $newfile | select pname

                let inits = difference $newnames $oldnames
                let drops = difference $oldnames $newnames 
                let updates = $oldfile | join $newfile pname | filter { |x| $x.version != $x.version_ }

                let inittext = $inits 
                    | each { |x| 
                        let version = $newfile | where pname == $x.pname | first | get version
                        $'($x.pname): init at ($version)'
                    }
                    | to text

                let droptext = $drops 
                    | each { |x| $'($x.pname): drop' }
                    | to text

                let updatetext = $updates
                    | each { |x| $'($x.pname): ($x.version) -> ($x.version_)' }
                    | to text

                [ $inittext, $droptext, $updatetext ] | to text | ^sort
              '';
          meta = {
            inherit mainProgram;
            description = "Show what changed inside of `sources.json` in a pretty way";
          };
        };
    };
}
