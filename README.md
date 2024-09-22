# nix-homelab

## Getting started

### Install NixOS VM

- Virtual ISO Link: https://nixos.org/download/#nixos-iso
- VM Settings:
  - CPU: 3
  - Memory: 8
  - Video Card: VGA
  - Firmware: UEFI

### Initialize VM

- Connect to NixOS VM
- Set a password to enable SSH connection with `passwd` command
- Get IP addresse with `ip addr` command

On local env set up a public key for SSH connection

```sh
ssh-keygen -f ~/.ssh/nixos-homelab
ssh-copy-id -i ~/.ssh/nixos-homelab root@<IP_ADDRESS>
```

or manually add public key under server `~/.ssh/another-machine` file

### Rebuild config

- SSH into server
- (if not done yet), git clone repo `git clone git@github.com:gaelgoth/nix-homelab.git`

Build:

- Dry-run: sudo nixos-rebuild dry-activate --flake .#nixos-anywhere-vm
- Rebuild: sudo nixos-rebuild --flake .#nixos-anywhere-vm switch

## Local env utils

**Install `nixfmt`**

```sh
# install nixfmt globally
nix-env -iA nixpkgs.nixfmt

# Test
nixfmt --version

# Format file
nixfmt configuration.nix
```
