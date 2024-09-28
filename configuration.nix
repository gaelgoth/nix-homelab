{ modulesPath, config, lib, pkgs, inputs, ... }:
let
  nasIp = "192.168.1.2";
  nfsDefaultOptions =
    [ "nofail" "noatime" "nolock" "intr" "tcp" "actimeo=1800" ];
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];

  sops = {
    age.keyFile = "/root/.config/sops/age/keys.txt";
    defaultSopsFile = ./secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
  };

  sops.secrets.example-key = { };
  sops.secrets.example-key = { };
  sops.secrets."myservice/my_subdir/my_secret" = { owner = "root"; };

  systemd.services."root" = {
    script = ''
      echo "
      Hey bro! I'm a service, and imma send this secure password:
      $(cat ${config.sops.secrets."myservice/my_subdir/my_secret".path})
      located in:
      ${config.sops.secrets."myservice/my_subdir/my_secret".path}
      to database and hack the mainframe
      " > /var/lib/root/testfile
    '';
    serviceConfig = {
      User = "root";
      WorkingDirectory = "/var/lib/root";
    };
  };

  # allow unfree packages to be installed
  nixpkgs.config = { allowUnfree = true; };

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking = {
    hostName = "nixos"; # Define your hostname.
    firewall.enable = true;

    # Set static IP for ens3
    interfaces.ens3.useDHCP = false;
    interfaces.ens3.ipv4.addresses = [{
      address = "192.168.1.5";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.2" "8.8.8.8" "1.1.1.1" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # UNCOMMENT this to enable docker
  virtualisation.docker.enable = true;

  programs.fish.enable = true;

  security.sudo.wheelNeedsPassword = false;

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    # UNCOMMENT this to enable headscale
    # headscale.enable = true;

    # UNCOMMENT this to enable a prometheus node exporter
    # prometheus.exporters.node.enable = true;

    # UNCOMMENT this to enable homeassistant-satellite - it's prob necessary to add more configuration here
    # homeassistant-satellite.enable = true;
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.nano
    pkgs.ncdu
    pkgs.nixfmt
    pkgs.sops

    # UNCOMMENT the following to install these packages systemwide
    # pkgs.jq
    # pkgs.neovim
    # pkgs.fzf
  ];

  users.users = {

    root = {
      # change this to your ssh key
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIdoZbVnha4FIh3Kci/9KOiSkbdHHDzTk3P1am6djOL/ root@docker-desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3aMW6GMHZ68Iw4v9+HPgbbd/uyUPMWLl6rcroY5LIR gael@mac.lan"
      ];
    };

    # UNCOMMENT the following to enable the nixos user
    # nixos = {
    #   isNormalUser = true;
    #   shell = pkgs.fish;
    #   description = "nixos user";
    #   extraGroups = [
    #     "networkmanager"
    #     "wheel"
    #     "docker"
    #   ];
    #   openssh.authorizedKeys.keys = [
    #     "CHANGE"
    #   ];
    # };

  };

  # NFS
  fileSystems = {
    "/mnt/media" = {
      device = "${nasIp}:/volume1/media";
      fsType = "nfs";
      options = nfsDefaultOptions;
    };
    "/mnt/documents" = {
      device = "${nasIp}:/volume1/documents";
      fsType = "nfs";
      options = nfsDefaultOptions;
    };

    "/mnt/nvme" = {
      device = "${nasIp}:/volume2/nvme";
      fsType = "nfs";
      options = nfsDefaultOptions;
    };
  };

  system.stateVersion = "23.11";
}
