{ pkgs, ... }:
let
  dotnet = pkgs.dotnet-runtime_8;

  runtimeConfigName = "Vintagestory.runtimeconfig.json";
  patchedRuntimeConfig = builtins.toFile runtimeConfigName ''
    {
      "runtimeOptions": {
        "tfm": "net8.0",
        "framework": {
          "name": "Microsoft.NETCore.App",
          "version": "${dotnet.version}"
        },
        "configProperties": {
          "System.Reflection.Metadata.MetadataUpdater.IsSupported": false
        }
      }
    }
  '';

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
  preFixup = ''
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

    cp ${patchedRuntimeConfig} $out/share/vintagestory/${runtimeConfigName}
  '';

  vintagestory = pkgs.vintagestory.overrideAttrs {
    inherit preFixup;
  };

  vintagestory-beta = pkgs.vintagestory.overrideAttrs (
    final: prev: {
      version = "1.21.0-pre.2";

      buildInputs =
        (prev.buildInputs or [ ])
        ++ (with pkgs; [
          wayland
        ]);

      src = pkgs.fetchzip {
        url = "https://cdn.vintagestory.at/gamefiles/pre/vs_client_linux-x64_${final.version}.tar.gz";
        hash = "sha256-KxOVEUvVLsSWptWMVpb2JhxtrCzQMWYCb1tkfUDZWLg=";
      };

      inherit preFixup;
    }
  );
in
{
  inherit vintagestory vintagestory-beta;
  default = vintagestory;
}
