{ pkgs, ... }:
let
  wrapperFlags = pkgs.lib.trim (
    ''
      --prefix LD_LIBRARY_PATH : "''${runtimeLibs[@]}" \
      --set-default mesa_glthread true \
    '' # used for 1.21.0-pre.1, see https://github.com/anegostudios/VintageStory-Issues/issues/6086
    + ''
      --set XDG_SESSION_TYPE x11
    ''
  );

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
      version = "1.20.12";

      src = pkgs.fetchzip {
        url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${final.version}.tar.gz";
        hash = "sha256-GlxBpnQBk1yZfh/uPK83ODrwn/VoORA3gGkvcXy+nV8=";
      };

      preFixup = makePrefixup pkgs.dotnet-runtime_7;
    }
  );

  vintagestory-beta = pkgs.vintagestory.overrideAttrs (
    final: prev: {
      version = "1.21.0-rc.3";

      buildInputs =
        (prev.buildInputs or [])
        ++ (with pkgs; [
          wayland
        ]);

      src = pkgs.fetchzip {
        url = "https://cdn.vintagestory.at/gamefiles/unstable/vs_client_linux-x64_${final.version}.tar.gz";
        hash = "sha256-st/8UsJROlt36IYoQ8kpIXTIyKlViWTBnqAmtLMFIyY=";
      };

      preFixup = makePrefixup pkgs.dotnet-runtime_8;
    }
  );
in
{
  inherit vintagestory vintagestory-beta;
  default = vintagestory;
}
