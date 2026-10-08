{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # claude-code moves too fast for the stable channel to keep up; pull it from
    # unstable instead so `nix flake update nixpkgs-unstable` alone tracks new releases.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    # Pinned: upstream requires go >=1.25 from the next commit onward, which
    # nixos-25.05's go 1.24.10 can't build. This is the last commit still on go 1.24.
    sops-nix.url =
      "github:Mic92/sops-nix?rev=17eea6f3816ba6568b8c81db8a4e6ca438b30b7c";
    # Pinned to the locked rev so the nightly upgrade reuses the store-cached
    # source instead of re-fetching the GitHub codeload tarball (recurring 429).
    # Bump deliberately via `nix flake update hermes-agent`.
    hermes-agent.url =
      "github:NousResearch/hermes-agent?rev=8df0a03793784205833f9e0db12395aa33ada433";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, disko, hermes-agent
    , vscode-server, sops-nix, ... }: {
      nixosConfigurations.nixos-homelab-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit sops-nix; };
        modules = [
          disko.nixosModules.disko
          vscode-server.nixosModules.default
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          hermes-agent.nixosModules.default

          ./configuration.nix
          ./modules/homelab/core.nix

          ./modules/monitoring
          ./modules/tailscale
          ./modules/cloudflared
          ./modules/hermes
          ./modules/obsidian-sync

          ./containers/adguardhome
          ./containers/arr
          ./containers/changedetection
          ./containers/cleanuparr
          ./containers/dockge
          ./containers/dozzle
          ./containers/flaresolverr
          ./containers/glance
          ./containers/gluetun
          ./containers/handbrake
          ./containers/homepage
          ./containers/joal
          ./containers/metube
          ./containers/nginxproxymanager
          ./containers/pairdrop
          ./containers/qbittorrent
          ./containers/speedtest
          ./containers/stirlingpdf
          ./containers/syncthing
          ./containers/transmission
          ./containers/uptimekuma
          ./containers/wallos

          # ./containers/neko
          # ./containers/watchtower

          # ./containers/grafana # installed via nix package
          # ./containers/jellyfin

          ({ config, pkgs, ... }: { services.vscode-server.enable = true; })

          {
            nixpkgs.overlays = [
              (final: prev: {
                claude-code = (import nixpkgs-unstable {
                  inherit (prev) system;
                  config = prev.config;
                }).claude-code;
                obsidian-headless = (import nixpkgs-unstable {
                  inherit (prev) system;
                  config = prev.config;
                }).obsidian-headless;
              })
            ];
          }
        ];
      };
    };
}
