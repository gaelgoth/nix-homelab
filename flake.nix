{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = { self, nixpkgs, disko, vscode-server, sops-nix, ... }: {
    nixosConfigurations.nixos-anywhere-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit sops-nix; };
      modules = [
        disko.nixosModules.disko
        vscode-server.nixosModules.default
        sops-nix.nixosModules.sops

        ./configuration.nix
        ./containers/speedtest
        # ./containers/jellyfin

        ({ config, pkgs, ... }: { services.vscode-server.enable = true; })
      ];
    };
  };
}
