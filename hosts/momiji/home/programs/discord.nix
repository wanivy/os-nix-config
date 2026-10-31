{
  programs.nixcord = {
    enable = true;
    useGlobalPkgs = false;

    config.plugins = {
      addAttachments.enable = true;
      betterRoleContext = {
        enable = true;
        roleIconFileFormat = "png";
      };
      biggerStreamPreview.enable = true;
      consoleJanitor = {
        enable = true;
        allowLevel = {
          debug = false;
          error = true;
          info = false;
          log = false;
          trace = false;
          warn = false;
        };
        disableLoggers = false;
        disableSpotifyLogger = true;
        whitelistedLoggers = "GatewaySocket; Routing/Utils";
      };
      copyFileContents.enable = true;
      copyUserUrls.enable = true;
      crashHandler = {
        enable = true;
        attemptToNavigateToHome = false;
        attemptToPreventCrashes = true;
      };
      directFileDownload.enable = true;
      disableCallIdle.enable = true;
      equiTweaks = {
        enable = true;
        accountStandingButton = false;
        disableAdoptTagPrompt = false;
        forceRoleIcon = false;
        hideVoiceIndicatorForMutedChannels = false;
        jsonGateway = false;
        noBulletPoints = false;
        noMirroredCamera = false;
        noModalAnimation = false;
        removeActivitySection = false;
        restoreFileDownloadButton = false;
        showYourOwnActivityButtons = false;
      };
      experiments = {
        enable = true;
        toolbarDevMenu = false;
      };
      fakeNitro = {
        enable = false;
        disableEmbedPermissionCheck = false;
        emojiSize = 48;
        enableEmojiBypass = false;
        enableStickerBypass = false;
        enableStreamQualityBypass = true;
        hyperLinkText = "{{NAME}}";
        stickerSize = 160;
        transformCompoundSentence = false;
        transformEmojis = true;
        transformStickers = true;
        useEmojiHyperLinks = true;
        useHyperLinks = true;
        useStickerHyperLinks = true;
      };
      favoriteAnything.enable = true;
      fixSpotifyEmbeds = {
        enable = true;
        volume = 10.0;
      };
      forceOwnerCrown.enable = true;
      messageLatency = {
        enable = true;
        detectDiscordKotlin = true;
        ignoreSelf = false;
        latency = 2;
        showMillis = false;
      };
      messageLogger = {
        enable = true;
        collapseDeleted = false;
        deleteStyle = "text";
        ignoreBots = true;
        ignoreChannels = "";
        ignoreGuilds = "";
        ignoreSelf = false;
        ignoreSelfEdits = false;
        ignoreUsers = "";
        inlineEdits = true;
        logDeletedAttachments = true;
        logDeletes = true;
        logEdits = true;
        separatedDiffs = false;
        showEditDiffs = false;
      };
      newPluginsManager.enable = true;
      noTypingAnimation.enable = true;
      noUnblockToJump.enable = true;
      permissionsViewer = {
        enable = true;
        permissionsSortOrder = 0;
      };
      platformIndicators = {
        enable = true;
        colorMobileIndicator = true;
        consoleIcon = "equicord";
        list = true;
        messages = false;
        profiles = true;
        showBots = false;
      };
      quickMention.enable = true;
      revealAllSpoilers.enable = true;
      showHiddenChannels = {
        enable = true;
        channelStyle = 0;
        defaultAllowedUsersAndRolesDropdownState = true;
        hideUnreads = true;
        showMode = 0;
      };
      silentTyping = {
        enable = true;
        alwaysEnableInActiveVoiceChat = false;
        chatContextMenu = true;
        chatIcon = true;
        chatIconLeftClickAction = "channel";
        chatIconMiddleClickAction = "settings";
        chatIconRightClickAction = "global";
        contextMenu = true;
        defaultHidden = true;
        disabledLocations = "";
        enabledGlobally = true;
        enabledLocations = "";
        hideChatBoxTypingIndicators = false;
        hideMembersListTypingIndicators = false;
        isEnabled = true;
        showIcon = true;
        temporaryEnableThresholdDirectMessages = 0;
        temporaryEnableThresholdServers = 0;
      };
      translate = {
        enable = true;
        autoTranslate = false;
        deeplApiKey = "";
        kagiSession = "";
        receivedInput = "auto";
        receivedOutput = "ru";
        sentInput = "auto";
        sentOutput = "ru";
        service = "google";
        showAutoTranslateTooltip = true;
      };
      validUser.enable = true;
      viewIcons = {
        enable = true;
        format = "webp";
        imgSize = "1024";
      };
      voiceMessageTranscriber = {
        enable = true;
        embed = false;
        maintainHorizontal = false;
        quantized = true;
        selectedModel = "onnx-community/whisper-base";
        useGpu = true;
      };
    };

    discord = {
      branches = ["canary"];
      commandLineArgs = ["--ozone-platform=x11"];
      equicord.enable = true;
      krisp.enable = false;
      openASAR.enable = true;
    };
  };
}
