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
  HEVY_API_KEY=replace-me
  GITHUB_TOKEN=replace-me
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

### Hermes GitHub access

Hermes can propose changes to this repo itself, landed as a reviewable GitHub
PR — never by hand-editing your local `/root/nix-homelab` checkout or writing
to its own runtime config. It uses its bundled `github` skill
(`skills/software-development/github/SKILL.md`), which drives the whole
branch/commit/push/PR lifecycle through the `gh` CLI, authenticated via the
`GITHUB_TOKEN` set above. `git`/`openssh` already ship with the
`hermes-agent` package; `gh` is added via `extraPackages`. Commit identity
(`GIT_AUTHOR_NAME`/`GIT_AUTHOR_EMAIL`/committer equivalents) is set in
`modules/hermes/default.nix`.

Generate `GITHUB_TOKEN` as a **fine-grained personal access token** scoped to
just this repo (`gaelgoth/nix-homelab`), with only `Contents: Read & write`
and `Pull requests: Read & write` — not a classic broad `repo`-scope token.

Hermes works in its own clone under `/var/lib/hermes/workspace` (its default
terminal working directory), not your `/root/nix-homelab` checkout — it
never touches your local working tree. Review its PRs on GitHub, then
`git pull`/rebuild from your own checkout when ready.

**Strongly recommended:** enable branch protection on `main` on GitHub
(require a PR before merging, disallow direct pushes) so hermes — or a
leaked token — can never bypass review, regardless of what its skill/prompt
says to do.

**Logs, for self-diagnosis:** hermes's `hermes` user is in the
`systemd-journal` group, so it can read the full system journal — including
`nixos-upgrade.service` (auto-upgrade runs) and every container, since each
one here runs as a `podman-<name>.service` unit whose output already lands
in the journal. This lets it notice a failed auto-upgrade or a crashing
container and open a fix PR, without granting it write/control over
anything (`journalctl` access is read-only).

### Obsidian Sync

`obsidian-headless` (the official `ob` CLI, pulled from `nixpkgs-unstable` via
an overlay since it isn't in the pinned `nixos-25.05` channel) continuously
syncs an Obsidian Sync vault down to `/var/lib/obsidian-sync/vault` as the
dedicated `obsidian-sync` system user. Hermes gets read-only access to the
whole vault plus read-write access to `vault/Hermes/`, via the shared
`obsidian-vault` group and `OBSIDIAN_VAULT_PATH` (set in
`modules/hermes/default.nix`) — its bundled Obsidian skill reads/writes notes
straight off disk, no REST API plugin or GUI involved. No virtual
display/Electron is needed anywhere; `ob` is a plain Node CLI.

Deploy:

```sh
sudo nixos-rebuild dry-activate --flake .#nixos-homelab-vm
sudo nixos-rebuild switch --flake .#nixos-homelab-vm
```

The `obsidian-sync` service is gated by `ExecCondition = ob sync-status` and
stays inactive (not crash-looping) until the one-time interactive login and
vault link below have been done. This is the step to redo whenever the stored
credentials are lost/rotated or you're rebuilding this VM from scratch:

```sh
# Login to your Obsidian account (prompts for email/password/MFA)
sudo -u obsidian-sync -H ob login

# Find your vault's name or id
sudo -u obsidian-sync -H ob sync-list-remote

# Link the local vault dir to it (add --password for an end-to-end encrypted vault)
sudo -u obsidian-sync -H ob sync-setup --vault "<vault name>" --path /var/lib/obsidian-sync/vault

sudo systemctl start obsidian-sync
```

Verify:

```sh
systemctl status obsidian-sync
journalctl -u obsidian-sync -f

# should be readable, but only writable under Hermes/
sudo -u hermes -H ls -la /var/lib/obsidian-sync/vault
```

To re-point at a different vault, or after a botched setup:

```sh
sudo -u obsidian-sync -H ob sync-unlink --path /var/lib/obsidian-sync/vault
sudo -u obsidian-sync -H ob logout   # only if switching Obsidian accounts too
```

then repeat the login/sync-setup steps above.

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

## Test marker (Hermes PR workflow)

This section is a disposable marker added by Hermes to exercise the
branch → push → pull-request workflow. It exists only to confirm that Hermes
can propose changes to this repo as a reviewable GitHub PR rather than pushing
directly to `main`. It can be removed without any loss. (2026-09-18)
