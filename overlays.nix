self: super: {
  frescobaldi = super.frescobaldi.overrideAttrs (oldAttrs: {
    # extend old postInstall (if exists) with wrapProgram
    postInstall =
      (oldAttrs.postInstall or "")
      + ''
        wrapProgram $out/bin/frescobaldi --set QT_QPA_PLATFORM "wayland;xcb"
      '';
  });
}
