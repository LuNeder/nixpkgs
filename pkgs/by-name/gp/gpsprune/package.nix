{
  fetchurl,
  lib,
  stdenv,
  makeDesktopItem,
  makeWrapper,
  unzip,
  jre,
  copyDesktopItems,
}:

stdenv.mkDerivation rec {
  pname = "gpsprune";
  version = "25";

  src = fetchurl {
    url = "https://activityworkshop.net/software/gpsprune/gpsprune_${version}.jar";
    hash = "sha256-8FGOigjHIvj+CZwq0Lht7UZjtmrE5l2Aqx92gZjau44=";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];
  buildInputs = [ jre ];

  desktopItems = [
    (makeDesktopItem {
      name = "gpsprune";
      exec = "gpsprune %F";
      icon = "gpsprune";
      desktopName = "GpsPrune";
      genericName = "GPS Data Editor";
      comment = meta.description;
      categories = [
        "Education"
        "Geoscience"
      ];
      mimeTypes = [
        "application/gpx+xml"
        "application/vnd.google-earth.kml+xml"
        "application/vnd.google-earth.kmz"
      ];
    })
  ];

  installPhase = ''
    runHook preInstall

    install -Dm644 ${src} $out/share/java/gpsprune.jar
    makeWrapper ${jre}/bin/java $out/bin/gpsprune \
      --add-flags "-jar $out/share/java/gpsprune.jar"
    mkdir -p $out/share/pixmaps
    ${unzip}/bin/unzip -p $src tim/prune/gui/images/window_icon_64.png > $out/share/pixmaps/gpsprune.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "Application for viewing, editing and converting GPS coordinate data";
    homepage = "https://activityworkshop.net/software/gpsprune/";
    changelog = "https://activityworkshop.net/software/gpsprune/whats_new.html";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ rycee ];
    platforms = platforms.all;
    mainProgram = "gpsprune";
  };
}
