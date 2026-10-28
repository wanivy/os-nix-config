{
  services.flatpak = {
    enable = true;
    packages = ["org.vinegarhq.Sober"];
    update.auto = {
      enable = true;
      onCalendar = "daily";
    };
  };
}
