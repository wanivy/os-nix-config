{...}: {
  systemd.services.disable-logitech-receiver-wakeup = {
    description = "Disable wakeup from the Logitech USB receiver";
    wantedBy = ["sleep.target"];
    before = ["sleep.target"];

    serviceConfig.Type = "oneshot";
    script = ''
      for device in /sys/bus/usb/devices/*; do
        if [ -r "$device/idVendor" ] \
          && [ -r "$device/idProduct" ] \
          && [ "$(<"$device/idVendor")" = "046d" ] \
          && [ "$(<"$device/idProduct")" = "c547" ] \
          && [ -w "$device/power/wakeup" ]; then
          echo disabled > "$device/power/wakeup"
        fi
      done
    '';
  };
}
