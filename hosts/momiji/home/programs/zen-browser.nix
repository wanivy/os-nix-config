{
  programs.zen-browser = {
    enable = true;
    env = {
      LIBVA_DRIVER_NAME = "nvidia";
      MOZ_DISABLE_RDD_SANDBOX = "1";
      NVD_BACKEND = "direct";
    };
    profiles.default = {
      isDefault = true;
      search = {
        default = "google";
        force = true;
        privateDefault = "google";
      };
      settings = {
        "browser.aboutwelcome.enabled" = false;
        "browser.translations.automaticallyPopup" = false;
        "browser.translations.enable" = false;
        "general.autoScroll" = true;
        "media.av1.enabled" = false;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.ffvpx.enabled" = false;
        "media.hardware-video-decoding.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "middlemouse.paste" = false;
        "zen.view.sidebar-expanded" = false;
        "zen.view.use-single-toolbar" = false;
        "zen.welcome-screen.seen" = true;
      };
    };
    policies = let
      installExtension = slug: {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
        installation_mode = "normal_installed";
      };
    in {
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      OfferToSaveLogins = false;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      PasswordManagerEnabled = false;
      Permissions.Location.BlockNewRequests = true;
      PromptForDownloadLocation = true;
      TranslateEnabled = false;
      UserMessaging.SkipOnboarding = true;

      ExtensionSettings = {
        "uBlock0@raymondhill.net" = installExtension "ublock-origin";
        "{036a55b4-5e72-4d05-a06c-cba2dfcc134a}" = installExtension "traduzir-paginas-web";
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" =
          (installExtension "bitwarden-password-manager")
          // {
            default_area = "navbar";
          };
        "{cb31ec5d-c49a-4e5a-b240-16c767444f62}" = installExtension "indie-wiki-buddy";
        "{762f9885-5a13-4abd-9c77-433dcd38b8fd}" = installExtension "return-youtube-dislikes";
        "firefox-extension@steamdb.info" = installExtension "steam-database";
        "gdpr@cavi.au.dk" = installExtension "consent-o-matic";
        "jid1-MnnxcxisBPnSXQ@jetpack" = installExtension "privacy-badger17";
      };
    };
  };

  xdg.mimeApps = {
    enable = true;
    associations.added."application/pdf" = ["zen-beta.desktop"];
    defaultApplications = {
      "application/pdf" = ["zen-beta.desktop"];
      "text/html" = ["zen-beta.desktop"];
      "x-scheme-handler/http" = ["zen-beta.desktop"];
      "x-scheme-handler/https" = ["zen-beta.desktop"];
    };
  };
}
