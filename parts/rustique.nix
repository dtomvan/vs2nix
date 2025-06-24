{
  perSystem =
    { pkgs, ... }:
    {
      packages.rustique =
        let
          inherit (pkgs)
            lib
            rustPlatform
            fetchFromGitHub
            ;
        in
        rustPlatform.buildRustPackage (finalAttrs: {
          pname = "Rustique";
          version = "0.5.8";

          src = fetchFromGitHub {
            owner = "Tekunogosu";
            repo = "Rustique";
            rev = "v${finalAttrs.version}";
            hash = "sha256-AkvQGj0SoxbHlGJEzMkCF9DUbh97chT84czzs3jOAS8=";
          };

          # tries to use clang and /usr/bin/mold, let's just not do that, and
          # use the GNU toolchain from stdenv
          postPatch = "rm -vf .cargo/config.toml";

          cargoHash = "sha256-dcpM0rB0kFxTEgv1JJRPcxeha6SHOHkWwHT7Xw7hd8I=";

          # unstable rust feature path_add_extension
          env.RUSTC_BOOTSTRAP = 1;

          meta = {
            description = "The best Vintage Story mod manager you've never used";
            homepage = "https://github.com/Tekunogosu/Rustique";
            changelog = "https://github.com/Tekunogosu/Rustique/blob/${finalAttrs.src.rev}/changelog.md";
            license = lib.licenses.mit;
            mainProgram = "Rustique";
          };
        });
    };
}
