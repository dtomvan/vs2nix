{ pkgs, ... }:
let
  # TODO: remove after next nixpkgs bump
  wrapperFlags = pkgs.lib.trim ''
    --prefix LD_LIBRARY_PATH : "''${runtimeLibs[@]}" \
    --set-default mesa_glthread true
  '';

  # dotnet isn't overridable yet, so just do it like this right now
  makePrefixup = dotnet: ''
    makeWrapper ${pkgs.lib.getExe dotnet} $out/bin/vintagestory \
      ${wrapperFlags} \
      --add-flags $out/share/vintagestory/Vintagestory.dll

    makeWrapper ${pkgs.lib.getExe dotnet} $out/bin/vintagestory-server \
      ${wrapperFlags} \
      --add-flags $out/share/vintagestory/VintagestoryServer.dll

    find "$out/share/vintagestory/assets/" -not -path "*/fonts/*" -regex ".*/.*[A-Z].*" | while read -r file; do
      local filename="$(basename -- "$file")"
      ln -sf "$filename" "''${file%/*}"/"''${filename,,}"
    done
  '';

  vintagestory = pkgs.vintagestory.overrideAttrs (
    final: prev: {
      version = "1.21.0";

      src = pkgs.fetchzip {
        url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${final.version}.tar.gz";
        hash = "sha256-Adp6rOuJcjRHNjDm/nP/t8koYFgv6mRdHuvg0fuKzbA=";
      };

      preFixup = makePrefixup pkgs.dotnet-runtime_8;
    }
  );

  vintagestory-beta = pkgs.vintagestory.overrideAttrs (
    final: prev: {
      version = "1.21.1-rc.1";

      src = pkgs.fetchzip {
        url = "https://cdn.vintagestory.at/gamefiles/unstable/vs_client_linux-x64_${final.version}.tar.gz";
        hash = "sha256-jTImsd8KQNTAL8MFUl7pp3H/URyPGzvh1VKRTQPVc0c=";
      };

      preFixup = makePrefixup pkgs.dotnet-runtime_8;
    }
  );
in
{
  inherit vintagestory vintagestory-beta;
  default = vintagestory;
}
