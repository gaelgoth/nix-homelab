# nix-homelab (🧑🏾‍💻work in progress)

## Getting started

### TODOs

- Use https://github.com/nlewo/comin for auto update
- or use a cron script https://discourse.nixos.org/t/ci-cd-rebuilds-via-github/36059/6

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

### Git SSH key

```sh
mkdir ~/.ssh
cd  ~/.ssh
ssh-keygen -t rsa -b 4096 -C "nix@homelab.lan"

```

### Rebuild config

- SSH into server
- (if not done yet), git clone repo `git clone git@github.com:gaelgoth/nix-homelab.git`

Build:

- Dry-run: `sudo nixos-rebuild dry-activate --flake .#nixos-homelab-vm`
- Rebuild: `sudo nixos-rebuild --flake .#nixos-homelab-vm switch`

### Hermes Agent

Hermes runs as the native `hermes-agent` system service, uses OpenRouter with
`deepseek/deepseek-v4-flash-0731`, and accepts Telegram direct messages only
from the user ID configured in `vars.nix`. Telegram uses outbound long polling,
so no firewall port is required.

Edit the encrypted runtime credentials with SOPS:

```sh
sops secrets/secrets.yaml
```

The decrypted `hermes-env` value must have this format:

```yaml
hermes-env: |
  OPENROUTER_API_KEY=replace-me
  TELEGRAM_BOT_TOKEN=replace-me
```

Deploy and verify:

```sh
sudo nixos-rebuild dry-activate --flake .#nixos-homelab-vm
sudo nixos-rebuild switch --flake .#nixos-homelab-vm

systemctl status hermes-agent
journalctl -u hermes-agent -f
sudo -u hermes -H hermes --version
sudo -u hermes -H hermes config
```

The CLI and Telegram gateway share `HERMES_HOME` at
`/var/lib/hermes/.hermes`. Run interactive CLI commands with
`sudo -u hermes -H hermes` so files remain owned by the service account. Keep
personas, Markdown, skills, scripts, memories, and sessions under
`/var/lib/hermes` so they remain machine-only. Do not add them through
repository-backed `documents`, `hermesHomeFiles`, or `configFile` options. The
NixOS module manages `config.yaml` and the systemd service, so change
declarative settings in `modules/hermes/default.nix` and credentials in SOPS
instead of using `hermes setup`, `hermes config set`, or
`hermes gateway install`.

Update only Hermes, review the lockfile change, then redeploy:

```sh
nix flake update hermes-agent
nix flake check
sudo nixos-rebuild switch --flake .#nixos-homelab-vm
```

## Local env utils

**Install `nixfmt`**

```sh
# install sops globally
nix-env -iA nixpkgs.sops

# install nixfmt globally
nix-env -iA nixpkgs.nixfmt-rfc-style

# Test
nixfmt --version

# Format file
nixfmt configuration.nix
```

## Debug

```sh
# auto upgrade
systemctl start nixos-upgrade.service
systemctl status nix-gc
systemctl status nixos-upgrade

journalctl -u nixos-upgrade.service
```

## References

- `nixos-anywhere` with ARM Mac: https://seanrmurphy.medium.com/bringing-up-a-nixos-vm-in-10-minutes-using-nixos-anywhere-6590b49ad146
- Set up `sops-nix`: https://www.youtube.com/watch?v=G5f6GC7SnhU&t=1s
- Flake auto-upgrade: https://github.com/eh8/chenglab/blob/main/.github/workflows/flake.yml
