{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";
  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";

  outputs = { nixpkgs, disko, vscode-server, ... }: {
    nixosConfigurations.nixos-anywhere-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        vscode-server.nixosModules.default
        ./configuration.nix
        ({ config, pkgs, ... }: { services.vscode-server.enable = true; })
      ];
    };
  };
}
