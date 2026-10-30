{
  config,
  lib,
  ...
}: {
  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  disko.devices = {
    disk.main = {
      type = "disk";
      device = lib.mkDefault "/dev/disk/by-id/nvme-ADATA_LEGEND_710_2O4329QSC4CL";
      destroy = false;
      content = {
        type = "gpt";
        partitions = {
          data = {
            priority = 1;
            start = "2048s";
            end = "895356927s";
            type = "0700";
            uuid = "a085d7d3-59cd-4126-babb-f0458a7a85b7";
            label = "NVMe";
          };
          esp = {
            priority = 2;
            start = "895356928s";
            end = "897454079s";
            type = "EF00";
            uuid = "44a17fec-a8a7-42fe-8adb-39370ed85d6c";
            label = "YANBOOT";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["fmask=0077" "dmask=0077"];
            };
          };
          root = {
            priority = 3;
            start = "897454080s";
            end = "1000214527s";
            type = "8300";
            uuid = "46f914be-9b27-4706-b63d-c2bccf89d1eb";
            label = "yanville-root";
            content = {
              type = "filesystem";
              format = "btrfs";
              mountpoint = "/";
              mountOptions = ["defaults"];
            };
          };
        };
      };
    };

    nodev."/mnt/nvme" = {
      fsType = "ntfs3";
      device = "/dev/disk/by-uuid/2E4034F54034C57D";
      mountOptions = [
        "rw"
        "uid=1000"
        "gid=100"
        "umask=0022"
        "nofail"
        "x-systemd.device-timeout=5s"
      ];
    };
  };

  swapDevices = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.enableRedistributableFirmware = lib.mkDefault true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
