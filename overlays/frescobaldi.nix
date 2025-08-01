final: prev: {
  frescobaldi =
    with prev;
    python3Packages.buildPythonApplication rec {
      pname = "frescobaldi";
      version = "4.0.3";

      src = fetchFromGitHub {
        owner = "frescobaldi";
        repo = "frescobaldi";
        tag = "v${version}";
        sha256 = "sha256-fTTHhoQJUOYncYkKb9jwp9i0hCoQpClvVlil/A6r8UI=";
      };

      propagatedBuildInputs = with python3Packages; [
        lilypond
        pyqt6-webengine
        python-ly
        qpageview
      ];

      nativeBuildInputs = with python3Packages; [
        pyqtwebengine.wrapQtAppsHook
        tox
        hatchling
        pygame-ce
      ];

      pyproject = true;

      preBuild = ''
        tox -e mo-generate
        tox -e linux-generate
      '';

      postPatch = "sed -i '/license = {text =/d' pyproject.toml";

      # no tests in shipped with upstream
      doCheck = false;

      dontWrapQtApps = true;
      makeWrapperArgs = [
        "\${qtWrapperArgs[@]}"
      ];

      meta = with lib; {
        homepage = "https://frescobaldi.org/";
        description = "LilyPond sheet music text editor";
        longDescription = ''
          Powerful text editor with syntax highlighting and automatic completion,
          Music view with advanced Point & Click, Midi player to proof-listen
          LilyPond-generated MIDI files, Midi capturing to enter music,
          Powerful Score Wizard to quickly setup a music score, Snippet Manager
          to store and apply text snippets, templates or scripts, Use multiple
          versions of LilyPond, automatically selects the correct version, Built-in
          LilyPond documentation browser and built-in User Guide, Smart
          layout-control functions like coloring specific objects in the PDF,
          MusicXML import, Modern user iterface with configurable colors,
          fonts and keyboard shortcuts
        '';
        license = licenses.gpl2Plus;
        maintainers = with maintainers; [ sepi ];
        platforms = platforms.all;
        broken = stdenv.hostPlatform.isDarwin; # never built on Hydra https://hydra.nixos.org/job/nixpkgs/trunk/frescobaldi.x86_64-darwin
        mainProgram = "frescobaldi";
      };
    };
}
