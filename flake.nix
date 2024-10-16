{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    comin = {
      url = "github:nlewo/comin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, disko, vscode-server, sops-nix, comin, ... }: {
    nixosConfigurations.nixos-homelab-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit sops-nix;
        vars = import ./vars.nix;
      };
      modules = [
        disko.nixosModules.disko
        vscode-server.nixosModules.default
        sops-nix.nixosModules.sops

        comin.nixosModules.comin
        ({ ... }: {
          services.comin = {
            enable = true;
            remotes = [{
              name = "origin";
              url = "https://github.com/gaelgoth/nix-homelab.git";
              branches.main.name = "main";
            }];
          };
        })

        ./configuration.nix

        ./modules/monitoring

        ./containers/arr
        ./containers/changedetection
        ./containers/dockge
        ./containers/dozzle
        ./containers/grafana
        ./containers/handbrake
        ./containers/homepage
        ./containers/neko
        ./containers/pairdrop
        ./containers/qbittorrent
        ./containers/speedtest
        ./containers/stirlingpdf
        ./containers/uptimekuma

        # ./containers/jellyfin

        ({ config, pkgs, ... }: { services.vscode-server.enable = true; })
      ];
    };
  };
}
