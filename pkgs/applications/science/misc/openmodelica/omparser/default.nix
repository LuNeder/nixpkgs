{
  lib,
  pkg-config,
  jre8,
  libuuid,
  openmodelica,
  mkOpenModelicaDerivation,
}:

mkOpenModelicaDerivation {
  pname = "omparser";
  omdir = "OMParser";
  omdeps = [ openmodelica.omcompiler ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    jre8
    libuuid
  ];

  patches = [ ./Makefile.in.patch ];

  meta = with lib; {
    description = "Antlr4-based parser of Modelica files from OpenModelica
suite";
    homepage = "https://openmodelica.org";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [
      balodja
      smironov
    ];
    platforms = platforms.linux;
  };
}
