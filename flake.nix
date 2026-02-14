{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-openclaw.url = "github:openclaw/nix-openclaw";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-openclaw,
      disko,
      vscode-server,
      sops-nix,
      ...
    }:
    {
      nixosConfigurations.nixos-homelab-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit sops-nix nix-openclaw; };
        modules = [
          (
            { ... }:
            {
              nixpkgs.overlays = [ nix-openclaw.overlays.default ];
            }
          )
          disko.nixosModules.disko
          vscode-server.nixosModules.default
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager

          ./configuration.nix
          ./modules/homelab/core.nix

          ./modules/monitoring
          ./modules/tailscale
          ./modules/cloudflared
          ./modules/openclaw

          ./containers/adguardhome
          ./containers/arr
          ./containers/changedetection
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
          ./containers/transmission
          ./containers/uptimekuma
          ./containers/wallos

          # ./containers/neko
          # ./containers/watchtower

          # ./containers/grafana # installed via nix package
          # ./containers/jellyfin

          (
            { config, pkgs, ... }:
            {
              services.vscode-server.enable = true;
            }
          )
        ];
      };
    };
}
