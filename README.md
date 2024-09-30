# nix-homelab (🧑🏾‍💻work in progress)

## Getting started

### TODOs

- [ ] Homepage dynamic loading

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
- Get IP address with `ip addr` command

On local env set up a public key for SSH connection

```sh
ssh-keygen -f ~/.ssh/nixos-homelab
ssh-copy-id -i ~/.ssh/nixos-homelab root@<IP_ADDRESS>
```

or manually add public key under server `~/.ssh/another-machine` file.

- On local env. update `~/.ssh/config` file:

```txt
Host <IP_ADDRESS>
  HostName <IP_ADDRESS>
  User root
  IdentityFile ~/.ssh/another-machine
```

### SOPS

```sh
mkdir -p ~/.config/sops/age

# generate new key at ~/.config/sops/age/keys.txt
nix shell nixpkgs#age -c age-keygen -o ~/.config/sops/age/keys.txt

# generate new key at ~/.config/sops/age/keys.txt from private ssh key at ~/.ssh/private
nix run nixpkgs#ssh-to-age -- -private-key -i ~/.ssh/private > ~/.config/sops/age/keys.txt

# get a public key of ~/.config/sops/age/keys.txt
nix shell nixpkgs#age -c age-keygen -y ~/.config/sops/age/keys.txt
```

Set public key in `.sops.yaml`:

```yaml
keys:
  - &primary { { SET KEY HERE } }
creation_rules:
  - path_regex: secrets/secrets.yaml$
    key_groups:
      - age:
          - *primary
```

```shell
mkdir secret
# create sops secret (example: https://github.com/Mic92/sops-nix)
sops secrets.yaml
```

### Rebuild config

- SSH into server
- (if not done yet), git clone repo `git clone git@github.com:gaelgoth/nix-homelab.git`

Build:

- Dry-run: sudo nixos-rebuild dry-activate --flake .#nixos-anywhere-vm
- Rebuild: sudo nixos-rebuild --flake .#nixos-anywhere-vm switch

## Local env utils

**Install `nixfmt`**

```sh
# install sops globally
nix-env -iA nixpkgs.sops

# install nixfmt globally
nix-env -iA nixpkgs.nixfmt

# Test
nixfmt --version

# Format file
nixfmt configuration.nix
```
