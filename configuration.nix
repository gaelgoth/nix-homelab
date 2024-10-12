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
    hostName = "nixos";
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

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  programs.fish.enable = true;

  security.sudo.wheelNeedsPassword = false;

  services = {
    openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.nano
    pkgs.ncdu
    pkgs.nixfmt-classic
    pkgs.sops
    pkgs.podman-tui
    pkgs.docker-compose

    # UNCOMMENT the following to install these packages systemwide
    # pkgs.jq
    # pkgs.neovim
    # pkgs.fzf
  ];

  users.users = {

    root = {
      # change this to your ssh key
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKfjN8It6HvrbbF6jo2hIAu2AAvGKevBEtQ2HYAuBzxm gael@mac.lan"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBileQ5HAicVceiOgApWVAgr28/HFZJMjuglqPXnlHV gael@container.lan"
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
