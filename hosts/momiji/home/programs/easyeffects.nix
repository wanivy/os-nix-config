{
  services.easyeffects = {
    enable = true;
    preset = "voice-c270";
    extraPresets.voice-c270.input = {
      blocklist = [];
      plugins_order = ["rnnoise#0" "gate#0" "compressor#0"];

      "rnnoise#0" = {
        bypass = false;
        enable-vad = true;
        input-gain = 0;
        model-name = "\"\"";
        output-gain = 0;
        release = 40;
        use-standard-model = true;
        vad-thres = 50;
        wet = 0;
      };

      "gate#0" = {
        attack = 4;
        bypass = false;
        curve-threshold = -48;
        curve-zone = -8;
        dry = -80.01;
        hpf-frequency = 80;
        hpf-mode = "12 dB/oct";
        hysteresis = true;
        hysteresis-threshold = -54;
        hysteresis-zone = -6;
        input-gain = 0;
        input-to-link = -80.01;
        input-to-sidechain = -80.01;
        link-to-input = -80.01;
        link-to-sidechain = -80.01;
        lpf-frequency = 12000;
        lpf-mode = "12 dB/oct";
        makeup = 0;
        output-gain = 0;
        reduction = -12;
        release = 220;
        sidechain = {
          lookahead = 0;
          mode = "RMS";
          preamp = 0;
          reactivity = 20;
          source = "Middle";
          stereo-split-source = "Left/Right";
          type = "Internal";
        };
        sidechain-to-input = -80.01;
        sidechain-to-link = -80.01;
        stereo-split = false;
        wet = 0;
      };

      "compressor#0" = {
        attack = 15;
        boost-amount = 6;
        boost-threshold = -72;
        bypass = false;
        dry = -80.01;
        hpf-frequency = 80;
        hpf-mode = "12 dB/oct";
        input-gain = 0;
        input-to-link = -80.01;
        input-to-sidechain = -80.01;
        knee = -6;
        link-to-input = -80.01;
        link-to-sidechain = -80.01;
        lpf-frequency = 12000;
        lpf-mode = "12 dB/oct";
        makeup = 6;
        mode = "Downward";
        output-gain = -1;
        ratio = 3;
        release = 120;
        release-threshold = -80.01;
        sidechain = {
          lookahead = 0;
          mode = "RMS";
          preamp = 0;
          reactivity = 20;
          source = "Middle";
          stereo-split-source = "Left/Right";
          type = "Feed-forward";
        };
        sidechain-to-input = -80.01;
        sidechain-to-link = -80.01;
        stereo-split = false;
        threshold = -27;
        wet = 0;
      };
    };
  };
}
