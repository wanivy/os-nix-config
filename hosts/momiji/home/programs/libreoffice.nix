{
  lib,
  pkgs,
  ...
}: let
  writer = [
    "application/msword"
    "application/vnd.ms-word"
    "application/x-doc"
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    "application/vnd.openxmlformats-officedocument.wordprocessingml.template"
    "application/vnd.ms-word.document.macroEnabled.12"
    "application/vnd.ms-word.template.macroEnabled.12"
    "application/rtf"
    "text/rtf"
    "application/vnd.oasis.opendocument.text"
    "application/vnd.oasis.opendocument.text-template"
    "application/vnd.oasis.opendocument.text-flat-xml"
    "application/vnd.oasis.opendocument.text-master"
    "application/vnd.oasis.opendocument.text-master-template"
  ];
  calc = [
    "application/excel"
    "application/msexcel"
    "application/vnd.ms-excel"
    "application/x-dos_ms_excel"
    "application/x-excel"
    "application/x-ms-excel"
    "application/x-msexcel"
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    "application/vnd.openxmlformats-officedocument.spreadsheetml.template"
    "application/vnd.ms-excel.sheet.macroEnabled.12"
    "application/vnd.ms-excel.sheet.binary.macroEnabled.12"
    "application/vnd.ms-excel.template.macroEnabled.12"
    "application/vnd.ms-excel.addin.macroEnabled.12"
    "application/vnd.oasis.opendocument.spreadsheet"
    "application/vnd.oasis.opendocument.spreadsheet-template"
    "application/vnd.oasis.opendocument.spreadsheet-flat-xml"
    "application/csv"
    "application/tab-separated-values"
    "text/csv"
    "text/comma-separated-values"
    "text/x-csv"
    "text/x-comma-separated-values"
    "text/tab-separated-values"
    "text/spreadsheet"
  ];
  impress = [
    "application/mspowerpoint"
    "application/vnd.ms-powerpoint"
    "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    "application/vnd.openxmlformats-officedocument.presentationml.template"
    "application/vnd.openxmlformats-officedocument.presentationml.slideshow"
    "application/vnd.openxmlformats-officedocument.presentationml.slide"
    "application/vnd.ms-powerpoint.presentation.macroEnabled.12"
    "application/vnd.ms-powerpoint.template.macroEnabled.12"
    "application/vnd.ms-powerpoint.slideshow.macroEnabled.12"
    "application/vnd.ms-powerpoint.slide.macroEnabled.12"
    "application/vnd.oasis.opendocument.presentation"
    "application/vnd.oasis.opendocument.presentation-template"
    "application/vnd.oasis.opendocument.presentation-flat-xml"
  ];
  applications =
    lib.genAttrs writer (_: ["libreoffice-writer.desktop"])
    // lib.genAttrs calc (_: ["libreoffice-calc.desktop"])
    // lib.genAttrs impress (_: ["libreoffice-impress.desktop"]);
in {
  home.packages = with pkgs; [
    libreoffice-fresh
    hunspell
    hunspellDicts.en_US
    hunspellDicts.ru_RU
    hunspellDicts.pl_PL
    hunspellDicts.uk_UA
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = applications;
    associations.added = applications;
  };
}
