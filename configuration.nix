{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  #To use nixos-anywhere to deploy to a remote computer, use the following snippet.
  #nix run github:nix-community/nixos-anywhere -- --flake .#generic --generate-hardware-config nixos-generate-config ./hardware-configuration.nix root@10.0.0.66
  #Afterwards, copy the files to the remote machine
  #scp -r ./nixos/ root@10.0.0.65:/etc/

  imports = [
    ./disk-config.nix
  ];

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking = {
    hostName = "hab-lab-1"; # Define your hostname.
    firewall.enable = true;
  };

  # allow unfree packages to be installed
  nixpkgs.config = {
    allowUnfree = true;
  };

  services.openssh.enable = true;

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  # environment.etc."nextcloud-admin-pass".text = "tobedetermined";
  # services.nextcloud = {
  #   enable = true;
  #   package = pkgs.nextcloud30;
  #   hostName = "localhost";
  #   config.adminpassFile = "/etc/nextcloud-admin-pass";
  #   config.dbtype = "sqlite";
  # };
  
  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        ~/keys/glacier.pub
        ~/keys/warframe.pub
      ];
      initialHashedPassword="$y$j9T$RbcN4mdZop6gD9K4x07AH/$XKRWxzJnp8gJM3UF/W8p8DwvC4EADEAsvxFU0KDCbw7";
    };
    hab-lab = {
      openssh.authorizedKeys.keys = [
        ~/keys/glacier.pub
        ~/keys/warframe.pub
      ];
      initialHashedPassword="$y$j9T$Sf7eBuwg3KS3NXUp8IMms.$GCdlKkeFZy1.o9HJq4UL2VGuS3MqdGZ.ezjQexd5LI.";
      isNormalUser = true; 
    };
  };

  system.stateVersion = "24.05";
}
