{
  config,
  lib,
  # pkgs,
  # settings,
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

    xdg.mimeApps = {
      enable = true;
      defaultApplications = utils.mimeToAppMap {
        "org.gnome.Loupe.desktop" = imageTypes;
        "librewolf.desktop" = [
          "x-scheme-handler/http"
          "application/xhtml+xml"
          "text/html"
          "x-scheme-handler/https"
        ];
        "org.gnome.Evince.desktop" = [ "application/pdf" ];
        "proton-mail.desktop" = [
          "x-scheme-handler/mailto"
          "message/rfc822"
          "x-scheme-handler/mid"
        ];
        "org.gnome.Decibels.desktop" = audioTypes;
        "org.gnome.Totem.desktop" = videoTypes;
      };
    };
  };
}
