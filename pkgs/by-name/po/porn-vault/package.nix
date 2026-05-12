{
  fetchFromGitLab,
  rustPlatform,
  lib,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  stdenv,
  nodejs_25,
  ffmpeg,
  imagemagick,
  openssl,
  pkg-config,
  makeWrapper,
}:
let
  nodejs = nodejs_25;
  pnpm' = pnpm_10.override { nodejs = nodejs_25; };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "porn-vault";
  version = "0.40.0-beta.0";

  src = fetchFromGitLab {
    owner = "porn-vault";
    repo = "porn-vault";
    rev = "740b844b14763a6f37e2fbeaf73822f6c3ffa0d3";
    hash = "sha256-gIe1wXUBPc7QARP7eSozUDhQ4QyDGgQ/XvIhNRVUp+o=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    prePatch = ''
      cd app
    '';
    pnpm = pnpm';
    fetcherVersion = 3;
    hash = "sha256-L9fe2DMbjPp/vzGvAgsHheZozAiuZyTWN1b/qiOalxg=";
  };

  nativeBuildInputs = [
    pkg-config
    openssl
    nodejs
    pnpmConfigHook
    pnpm'
    makeWrapper
  ];

  cargoHash = "sha256-T1JUZxOGFxEoFuYTFaD2oplZKxl1f80boR1wqDjsG5M=";

  prePnpmInstall = ''
    cd app
  '';

  postPatch = ''
    substituteInPlace vault/src/temp.rs \
      --replace-fail 'PV_TMP_FOLDER' "CACHE_DIRECTORY"
  '';

  preBuild = ''
    pnpm build
  '';

  PKG_CONFIG_PATH = "${openssl.dev}/lib/pkgconfig";

  doCheck = false;

  installPhase = ''
    runHook preInstall

    cd ..
    mkdir -p $out/bin
    cp ./target/${stdenv.hostPlatform.config}/release/pv $out/bin/porn-vault-unwrapped

    runHook postInstall
  '';

  preFixup = ''
    makeWrapper "$out/bin/porn-vault-unwrapped" "$out/bin/porn-vault" \
      --prefix PATH : "${
        lib.makeBinPath [
          ffmpeg
          imagemagick
          openssl
        ]
      }"
  '';

  meta = {
    description = "Self-hosted organizer for adult videos and imagery";
    homepage = "https://gitlab.com/porn-vault/porn-vault";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.luNeder ];
    inherit (nodejs.meta) platforms;
    mainProgram = "porn-vault";
  };
})
