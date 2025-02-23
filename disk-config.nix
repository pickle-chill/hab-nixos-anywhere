{ lib, ... }:
let
  zfsDisk = diskId: {
    type = "disk";
    device = "/dev/sd" + diskId;
    content = {
      type = "gpt";
      partitions = {
        zsf = {
          size = "100%";
	        content = {
            type = "zfs";
	          pool = "rpool";
	        };
	      };
      };
    };
  };
  in
  {
    networking.hostId = lib.mkForce "007f0201";
    disko.devices = {
      disk = {
        main = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              name = "boot";
              size = "1M";
              type = "EF02";
            };
            esp = {
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "btrfs";
                mountpoint = "/";
                mountOptions = [ "compress=zstd" "noatime"];
              };
            };
          };
        };
        };
        sda = zfsDisk "a";
        sdb = zfsDisk "b";
        sdc = zfsDisk "c";
      };
      zpool = {
        rpool = {
          type = "zpool";
          mode = "mirror";
          rootFsOptions = {
            compression = "zstd";
            "com.sun:auto-snapshot" = "false";
          };
          postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^rpool@blank$' || zfs snapshot rpool@blank";
          mountpoint = "/local";
          datasets = {
            local = {
              type = "zfs_fs";
              options."com.sun:auto-snapshot" = "true";
            };
            "local/nix" = {
              type = "zfs_fs";
              mountpoint = "/local/nix";
              options = {
                atime = "off";
                canmount = "on";
                mountpoint = "legacy";
                "com.sun:auto-snapshot" = "true";
              };
            };
          };
        };
      };
    };
  }
