# nix-homelab (🧑🏾‍💻work in progress)

## Getting started

### TODOs

### Install NixOS VM

- Virtual ISO Link: https://nixos.org/download/#nixos-iso
- VM Settings:
  - CPU: 3
  - Memory: 8
  - Video Card: VGA
  - Firmware: UEFI

### Initialize VM

- Connect to NixOS VM
- Set a password to enable SSH connection with `sudo passwd` command
- Get IP address with `ip addr` command

On local env set up a public key for SSH connection

> [!NOTE] To ease deployment a container with `linux/amd64` because of some incompatibility with my ARM64 MacBook Pro

```sh
docker compose -f misc/docker-compose.yml up
docker exec -it nix /bin/sh
```

```sh
# From Mac
ssh-keygen -f ~/.ssh/nix-homelab-mac -C "gael@mac.lan"
ssh-copy-id -i ~/.ssh/nix-homelab-mac root@<IP_ADDRESS>

# From Container
ssh-keygen -f ~/.ssh/nix-homelab-container -C "gael@container.lan"
# Then copy the public key generated and put it in /root/.ssh/authorized_keys on the VM
```

or manually add public key under server `~/.ssh/another-machine` file.

- On local env. update `~/.ssh/config` file:

```txt
Host <IP_ADDRESS>
  HostName <IP_ADDRESS>
  User root
  IdentityFile ~/.ssh/another-machine
```

- Double check disk device name with `lsblk`, if not `sda` update `disk-config.nix`
- **Important** Update SSH keys in `configuration.nix`
- From container run these commands:

```sh
cd workdir

nix run github:nix-community/nixos-anywhere -- --flake .#nixos-homelab-vm root@<IP_ADDRESS>
```

Once deployment is finished

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

- Dry-run: sudo nixos-rebuild dry-activate --flake .#nixos-homelab-vm
- Rebuild: sudo nixos-rebuild --flake .#nixos-homelab-vm switch

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

## References

- `nixos-anywhere` with ARM Mac: https://seanrmurphy.medium.com/bringing-up-a-nixos-vm-in-10-minutes-using-nixos-anywhere-6590b49ad146
- Set up `sops-nix`: https://www.youtube.com/watch?v=G5f6GC7SnhU&t=1s
