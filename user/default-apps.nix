{
  config,
  lib,
  pkgs,
  settings,
  ...
}:
let
  imageTypes = [
    "image/jpeg"
    "image/png"
    "image/gif"
    "image/webp"
    "image/tiff"
    "image/x-tga"
    "image/vnd-ms.dds"
    "image/x-dds"
    "image/bmp"
    "image/vnd.microsoft.icon"
    "image/vnd.radiance"
    "image/x-exr"
    "image/x-portable-bitmap"
    "image/x-portable-graymap"
    "image/x-portable-pixmap"
    "image/x-portable-anymap"
    "image/x-qoi"
    "image/qoi"
    "image/svg+xml"
    "image/svg+xml-compressed"
    "image/avif"
    "image/heic"
    "image/jxl"
  ];
  audioTypes = [
    "audio/mpeg"
    "audio/wav"
    "audio/x-aac"
    "audio/x-aiff"
    "audio/x-ape"
    "audio/x-flac"
    "audio/x-m4a"
    "audio/x-m4b"
    "audio/x-mp1"
    "audio/x-mp2"
    "audio/x-mp3"
    "audio/x-mpg"
    "audio/x-mpeg"
    "audio/x-mpegurl"
    "audio/x-opus+ogg"
    "audio/x-pn-aiff"
    "audio/x-pn-au"
    "audio/x-pn-wav"
    "audio/x-speex"
    "audio/x-vorbis"
    "audio/x-wavpack"
  ];
  videoTypes = [
    "video/3gp"
    "video/3gpp"
    "video/3gpp2"
    "video/dv"
    "video/divx"
    "video/fli"
    "video/flv"
    "video/mp2t"
    "video/mp4"
    "video/mp4v-es"
    "video/mpeg"
    "video/mpeg-system"
    "video/msvideo"
    "video/ogg"
    "video/quicktime"
    "video/vnd.divx"
    "video/vnd.mpegurl"
    "video/vnd.rn-realvideo"
    "video/webm"
    "video/x-anim"
    "video/x-avi"
    "video/x-flc"
    "video/x-fli"
    "video/x-flv"
    "video/x-m4v"
    "video/x-matroska"
    "video/x-mpeg"
    "video/x-mpeg2"
    "video/x-ms-asf"
    "video/x-ms-asf-plugin"
    "video/x-ms-asx"
    "video/x-msvideo"
    "video/x-ms-wm"
    "video/x-ms-wmv"
    "video/x-ms-wmx"
    "video/x-ms-wvx"
    "video/x-nsv"
    "video/x-theora"
    "video/x-theora+ogg"
    "video/x-ogm+ogg"
    "video/vivo"
    "video/vnd.vivo"
    "video/x-flic"
    "video/x-mjpeg"
    "video/x-totem-stream"
  ];

  makeCustomMime =
    comment: pattern:
    let
      normalized = lib.strings.toLower (lib.strings.replaceStrings [ " " ] [ "-" ] comment);
      mimeType = "text/x-${normalized}";
    in
    ''
      <mime-type type="${mimeType}">
        <comment>${comment}</comment>
        <glob pattern="${pattern}"/>
      </mime-type>
    '';

  ########################################################
  ### Define custom MIME types per file extension here ###
  ########################################################
  customTypes = [
    (makeCustomMime "Nix source code" "*.nix")
  ];
in
{
  options = {
    default-apps.utils = lib.mkOption {
      type = lib.types.attrs;
      default = "default value";
      description = "Utility functions";
    };
  };

  config = with config.default-apps; {

    home.file = {
      ".local/share/mime/packages/custom-code.xml".text =
        ''
          <?xml version="1.0" encoding="UTF-8"?>
          <mime-info xmlns="http://www.freedesktop.org/standards/shared-mime-info">
        ''
        + lib.concatStringsSep "\n" customTypes
        + "\n</mime-info>";
    };
    home.activation.updateMimeCache = lib.hm.dag.entryAfter [
      "writeBoundary"
    ] ''${pkgs.shared-mime-info}/bin/update-mime-database "${settings.homedir}/.local/share/mime"'';

    # check /home/aditya/.config/mimeapps.list for current associations
    # ls ~/.nix-profile/share/applications && ls /run/current-system/sw/share/applications
    # for available applications
    xdg.mimeApps = {
      enable = true;
      defaultApplications = utils.mimeToAppMap {
        "org.gnome.Loupe.desktop" = imageTypes;
        "org.gnome.Decibels.desktop" = audioTypes;
        "org.gnome.Totem.desktop" = videoTypes;

        "librewolf.desktop" = [
          "x-scheme-handler/http"
          "application/xhtml+xml"
          "text/html"
          "x-scheme-handler/https"
        ];
        "org.gnome.Evince.desktop" = [
          "application/pdf"
        ];
        "proton-mail.desktop" = [
          "x-scheme-handler/mailto"
          "message/rfc822"
          "x-scheme-handler/mid"
        ];
        "codium.desktop" = [
          "application/xml"
          "text/x-nix-source-code"
        ];
        "org.gnome.FileRoller.desktop" = [
          "application/zip"
        ];
        "org.gnome.TextEditor.desktop" = [
          "application/x-trash"
        ];
      };
    };
  };
}
