{
  config,
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "virtio_pci"
    "virtio_blk"
    "xhci_pci"
    "sd_mod"
    "sr_mod"
  ];
  boot.kernelModules = [
    "kvm-amd"
    "sit"
  ];

  disko.devices.disk.main = {
    type = "disk";
    device = lib.mkDefault "/dev/vda";
    destroy = false;
    content = {
      type = "gpt";
      partitions = {
        boot = {
          priority = 1;
          start = "2048s";
          end = "4095s";
          type = "EF02";
          uuid = "c126f983-5b1e-4b2d-82cf-fd6f60a0271c";
          label = "disk-main-boot";
        };
        root = {
          priority = 2;
          start = "4096s";
          end = "419428351s";
          type = "8300";
          uuid = "c8bd5db1-e898-495f-980c-f510c02b947e";
          label = "disk-main-root";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };

  swapDevices = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
