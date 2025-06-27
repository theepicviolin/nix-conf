final: prev: {
  cups-brother-hll2340dw = prev.cups-brother-hll2340dw.overrideAttrs (old: {
    installPhase =
      prev.cups-brother-hll2340dw.installPhase
      + ''
        substituteInPlace $out/opt/brother/Printers/HLL2340D/inf/brHLL2340Drc \
          --replace PaperType=A4 PaperType=Letter
      '';
  });
}
