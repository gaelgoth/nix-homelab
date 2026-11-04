{ modulesPath, config, lib, pkgs, inputs, ... }:
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

  # Reduce SSD wear: keep pages resident longer, and compress swap in RAM
  # (zswap), so far fewer swap pages are actually written to the backing disk.
  boot.kernelParams = [
    "vm.swappiness=10"
    "zswap.enabled=1"
    "zswap.compressor=zstd"
    "zswap.zpool=zsmalloc"
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    # Hard-link duplicate store files immediately after each build, so the
    # store stays deduplicated between the weekly `nix.optimise` runs.
    auto-optimise-store = true;
    substituters =
      [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDvhrs="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  networking = {
    hostName = "nixos-homelab-vm";
    firewall.enable = true;

    interfaces.ens3.useDHCP = false;
    interfaces.ens3.ipv4.addresses = [{
      address = config.homelab.ip;
      prefixLength = 24;
    }];
    defaultGateway = "192.168.1.1";
    nameservers = [ config.homelab.nasIp "8.8.8.8" "1.1.1.1" ];
  };

  time.timeZone = "Europe/Zurich";
  i18n.defaultLocale = "en_US.UTF-8";

  swapDevices = [{
    device = "/swapfile";
    size = 8192;
  }];

  virtualisation.containers.enable = true;
  virtualisation.containers.registries.search = [ "docker.io" "quay.io" ];

  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
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

    # Cap the journal and trim the filesystem weekly to limit write churn and
    # let the backing SSD reclaim blocks (reduces write amplification).
    fstrim.enable = true;

    journald.extraConfig = ''
      SystemMaxUse=256M
    '';
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.docker-compose
    pkgs.gitMinimal
    pkgs.nano
    pkgs.ncdu
    pkgs.nixfmt-classic
    pkgs.podman-tui
    pkgs.pre-commit
    pkgs.sops
    pkgs.tmux
    pkgs.claude-code
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
      device = "${config.homelab.nasIp}:/volume1/media";
      fsType = "nfs";
      options = nfsDefaultOptions;
    };
    "/mnt/documents" = {
      device = "${config.homelab.nasIp}:/volume1/documents";
      fsType = "nfs";
      options = nfsDefaultOptions;
    };
    "/mnt/nvme" = {
      device = "${config.homelab.nasIp}:/volume2/nvme";
      fsType = "nfs";
      options = nfsDefaultOptions;
    };
  };

  system.activationScripts.ensureBinDir = {
    deps = [ "specialfs" ];
    text = ''
      if [ -L /bin ]; then
        rm -f /bin
      fi
      if [ ! -d /bin ]; then
        mkdir -p /bin
      fi
      chmod 0755 /bin
    '';
  };

  system.activationScripts.binsh.deps = lib.mkAfter [ "ensureBinDir" ];

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

  # The daily upgrade runs `nixos-rebuild ... --refresh`, which re-fetches every
  # GitHub flake input on each run. The unauthenticated fetch budget
  # (60 req/hr/IP) is the root cause of the recurring 429 failures of
  # nixos-upgrade.service. Authenticate those fetches by reusing the GITHUB_TOKEN
  # already held in the hermes-env sops secret; an authenticated request gets a
  # 5,000 req/hr budget. systemd (>= 251) expands ${GITHUB_TOKEN} from the
  # EnvironmentFile into the NIX_CONFIG value, which the nix client driven by
  # nixos-rebuild honours for flake fetches.
  systemd.services.nixos-upgrade = {
    serviceConfig.EnvironmentFile = [ config.sops.secrets."hermes-env".path ];
    environment.NIX_CONFIG = "access-tokens=github.com=\${GITHUB_TOKEN}";
  };

  # Homelab shared option overrides (Phase 1 migration from vars.nix)
  homelab = {
    ip = "192.168.1.5";
    nasIp = "192.168.1.2";
    domain = "homelab.gothuey.dev";
    mediaPath = "/mnt/media";
  };

  system.stateVersion = "25.05";
}
