{ modulesPath, config, vars, lib, pkgs, inputs, ... }:
let
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

  nixpkgs.config = {
    allowUnfree = true;
    system = "x86_64-linux";
  };

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking = {
    hostName = "nixos-homelab-vm";
    firewall.enable = true;

    interfaces.ens3.useDHCP = false;
    interfaces.ens3.ipv4.addresses = [{
      address = vars.homelabStaticIp;
      prefixLength = 24;
    }];
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.2" "8.8.8.8" "1.1.1.1" ];
  };

  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled =
        false; # disable to allow :53 for adguardhome
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
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
    pkgs.docker-compose
    pkgs.gitMinimal
    pkgs.nano
    pkgs.ncdu
    pkgs.nixfmt-classic
    pkgs.podman-tui
    pkgs.sops
    pkgs.tmux
  ];

  users.users = {
    root = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKfjN8It6HvrbbF6jo2hIAu2AAvGKevBEtQ2HYAuBzxm gael@mac.lan"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBileQ5HAicVceiOgApWVAgr28/HFZJMjuglqPXnlHV gael@container.lan"
      ];
      home = "/root";
      extraGroups = [ "wheel" ];
    };
  };

  programs.ssh = {
    startAgent = true;
    extraConfig = ''
      Host github.com
        IdentityFile ~/.ssh/nix-homelab-github
        IdentitiesOnly yes
    '';
  };

  # NFS mounts
  fileSystems = {
    "/mnt/media" = {
      device = "${vars.nasStaticIp}:/volume1/media";
      fsType = "nfs";
      options = nfsDefaultOptions;
    };
    "/mnt/documents" = {
      device = "${vars.nasStaticIp}:/volume1/documents";
      fsType = "nfs";
      options = nfsDefaultOptions;
    };

    "/mnt/nvme" = {
      device = "${vars.nasStaticIp}:/volume2/nvme";
      fsType = "nfs";
      options = nfsDefaultOptions;
    };
  };

  nix.optimise = {
    automatic = true;
    dates = [ "Sun 03:00" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  # inspo: https://github.com/reckenrode/nixos-configs/blob/main/hosts/meteion/configuration.nix
  system.autoUpgrade = {
    enable = true;
    dates = "*-*-* 04:00:00";
    randomizedDelaySec = "1h";
    flake = "github:gaelgoth/nix-homelab";
  };

  system.stateVersion = "25.05";
}
