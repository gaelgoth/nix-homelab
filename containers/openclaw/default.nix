{
  config,
  lib,
  pkgs,
  ...
}:

let
  vars = import ../../vars.nix;

  # Workspace documents for agent personality
  agentsMd = pkgs.writeText "AGENTS.md" (builtins.readFile ./workspace/AGENTS.md);
  soulMd = pkgs.writeText "SOUL.md" (builtins.readFile ./workspace/SOUL.md);
  toolsMd = pkgs.writeText "TOOLS.md" (builtins.readFile ./workspace/TOOLS.md);
  homelabMd = pkgs.writeText "HOMELAB.md" (builtins.readFile ./workspace/HOMELAB.md);

  # CLI wrapper script for interacting with OpenClaw
  openclawCli = pkgs.writeShellScriptBin "openclaw" ''
    exec ${pkgs.podman}/bin/podman run --rm --network podman \
      -e HOME=/home/node \
      -v /var/lib/openclaw/config:/home/node/.openclaw:ro \
      ghcr.io/openclaw/openclaw:2026.1.29 \
      node dist/index.js "$@"
  '';
in
{
  # Add openclaw CLI to system packages
  environment.systemPackages = [ openclawCli ];

  # SOPS secrets for OpenClaw
  sops.secrets = {
    openclaw-anthropic-api-key = {
      sopsFile = ../../secrets/secrets.yaml;
    };
    openclaw-telegram-bot-token = {
      sopsFile = ../../secrets/secrets.yaml;
    };
    # Homelab service API keys (shared with homepage)
    jellyfin-api-key = {
      sopsFile = ../../secrets/secrets.yaml;
    };
    sonarr-api-key = {
      sopsFile = ../../secrets/secrets.yaml;
    };
    radarr-api-key = {
      sopsFile = ../../secrets/secrets.yaml;
    };
    prowlarr-api-key = {
      sopsFile = ../../secrets/secrets.yaml;
    };
    bazarr-api-key = {
      sopsFile = ../../secrets/secrets.yaml;
    };
    qbittorrent-admin-password = {
      sopsFile = ../../secrets/secrets.yaml;
    };
    grafana-password = {
      sopsFile = ../../secrets/secrets.yaml;
    };
    adguardhome-password = {
      sopsFile = ../../secrets/secrets.yaml;
    };
    changedetection-api-key = {
      sopsFile = ../../secrets/secrets.yaml;
    };
    jellyseerr-api-key = {
      sopsFile = ../../secrets/secrets.yaml;
    };
  };

  # Ensure config and workspace directories exist
  systemd.tmpfiles.rules = [
    "d /var/lib/openclaw 0755 root root -"
    "d /var/lib/openclaw/config 0755 root root -"
    "d /var/lib/openclaw/workspace 0755 root root -"
    "d /var/lib/openclaw/workspace/skills 0755 root root -"
  ];

  # Systemd service to write openclaw.json config with secrets
  systemd.services.openclaw-config = {
    description = "Generate OpenClaw configuration";
    wantedBy = [ "multi-user.target" ];
    before = [ "podman-openclaw.service" ];
    requiredBy = [ "podman-openclaw.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
            ANTHROPIC_KEY=$(cat ${config.sops.secrets.openclaw-anthropic-api-key.path})
            TELEGRAM_TOKEN=$(cat ${config.sops.secrets.openclaw-telegram-bot-token.path})

            # Load homelab service API keys
            JELLYFIN_KEY=$(cat ${config.sops.secrets.jellyfin-api-key.path})
            SONARR_KEY=$(cat ${config.sops.secrets.sonarr-api-key.path})
            RADARR_KEY=$(cat ${config.sops.secrets.radarr-api-key.path})
            PROWLARR_KEY=$(cat ${config.sops.secrets.prowlarr-api-key.path})
            BAZARR_KEY=$(cat ${config.sops.secrets.bazarr-api-key.path})
            QBITTORRENT_PASS=$(cat ${config.sops.secrets.qbittorrent-admin-password.path})
            GRAFANA_PASS=$(cat ${config.sops.secrets.grafana-password.path})
            ADGUARDHOME_PASS=$(cat ${config.sops.secrets.adguardhome-password.path})
            CHANGEDETECTION_KEY=$(cat ${config.sops.secrets.changedetection-api-key.path})
      JELLYSEERR_KEY=$(cat ${config.sops.secrets.jellyseerr-api-key.path})

            # Generate a gateway token if not exists
            if [ ! -f /var/lib/openclaw/config/gateway-token ]; then
              head -c 32 /dev/urandom | base64 | tr -d '/+=' | head -c 32 > /var/lib/openclaw/config/gateway-token
              chmod 600 /var/lib/openclaw/config/gateway-token
              chown 1000:1000 /var/lib/openclaw/config/gateway-token
            fi
            GATEWAY_TOKEN=$(cat /var/lib/openclaw/config/gateway-token)

            cat > /var/lib/openclaw/config/openclaw.json << 'CONFIGEOF'
      {
        "agents": {
          "defaults": {
            "model": {
              "primary": "anthropic/claude-sonnet-4-5-20250929"
            },
            "workspace": "/home/node/.openclaw/workspace",
            "sandbox": {
              "mode": "off"
            }
          }
        },
        "channels": {
          "telegram": {
            "enabled": true,
            "botToken": "TELEGRAM_TOKEN_PLACEHOLDER",
            "dmPolicy": "allowlist",
            "allowFrom": ["${toString vars.telegramUserId}"]
          }
        },
        "gateway": {
          "mode": "local",
          "trustedProxies": ["10.88.0.0/16", "172.16.0.0/12"],
          "bind": "lan",
          "port": 18789,
          "controlUi": {
            "enabled": true,
            "allowInsecureAuth": true
          },
          "auth": {
            "mode": "token",
            "token": "GATEWAY_TOKEN_PLACEHOLDER"
          }
        }
      }
      CONFIGEOF

            # Replace placeholders with actual values
            ${pkgs.gnused}/bin/sed -i "s|TELEGRAM_TOKEN_PLACEHOLDER|$TELEGRAM_TOKEN|g" /var/lib/openclaw/config/openclaw.json
            ${pkgs.gnused}/bin/sed -i "s|GATEWAY_TOKEN_PLACEHOLDER|$GATEWAY_TOKEN|g" /var/lib/openclaw/config/openclaw.json

            chmod 644 /var/lib/openclaw/config/openclaw.json
            chown -R 1000:1000 /var/lib/openclaw/config

            # Copy workspace documents
            cp ${agentsMd} /var/lib/openclaw/workspace/AGENTS.md
            cp ${soulMd} /var/lib/openclaw/workspace/SOUL.md
            cp ${toolsMd} /var/lib/openclaw/workspace/TOOLS.md
            cp ${homelabMd} /var/lib/openclaw/workspace/HOMELAB.md
            chmod 644 /var/lib/openclaw/workspace/*.md
            chown -R 1000:1000 /var/lib/openclaw/workspace

            # Write environment file with API keys for homelab services
            cat > /var/lib/openclaw/config/env << ENVEOF
      ANTHROPIC_API_KEY=$ANTHROPIC_KEY
      JELLYFIN_API_KEY=$JELLYFIN_KEY
      SONARR_API_KEY=$SONARR_KEY
      RADARR_API_KEY=$RADARR_KEY
      PROWLARR_API_KEY=$PROWLARR_KEY
      BAZARR_API_KEY=$BAZARR_KEY
      QBITTORRENT_PASSWORD=$QBITTORRENT_PASS
      GRAFANA_PASSWORD=$GRAFANA_PASS
      ADGUARDHOME_PASSWORD=$ADGUARDHOME_PASS
      CHANGEDETECTION_API_KEY=$CHANGEDETECTION_KEY
      JELLYSEERR_API_KEY=$JELLYSEERR_KEY
      ENVEOF
            chmod 600 /var/lib/openclaw/config/env
            chown 1000:1000 /var/lib/openclaw/config/env
    '';
  };

  virtualisation.oci-containers.containers.openclaw = {
    image = "ghcr.io/openclaw/openclaw:2026.1.30";
    autoStart = true;
    extraOptions = [
      "--init"
      "-l=homepage.group=AI"
      "-l=homepage.name=OpenClaw"
      "-l=homepage.icon=robot.png"
      "-l=homepage.href=http://${vars.homelabIp}:18789"
      "-l=homepage.description=Personal AI Assistant"
    ];
    ports = [
      "18789:18789"
    ];
    environmentFiles = [
      "/var/lib/openclaw/config/env"
    ];
    environment = {
      HOME = "/home/node";
      TERM = "xterm-256color";
      NODE_ENV = "production";
    };
    volumes = [
      "/var/lib/openclaw/config:/home/node/.openclaw"
      "/var/lib/openclaw/workspace:/home/node/.openclaw/workspace"
    ];
    cmd = [
      "node"
      "dist/index.js"
      "gateway"
      "--bind"
      "lan"
      "--port"
      "18789"
      "--verbose"
    ];
  };

  # Open firewall port for OpenClaw gateway
  networking.firewall.allowedTCPPorts = [ 18789 ];
}
