{ config, pkgs, ... }:
let
  vars = import ../../vars.nix;
in
{
  sops.secrets."hermes-env" = {
    restartUnits = [ "hermes-agent.service" ];
  };

  sops.secrets."hermes-dashboard-token" = {
    owner = "hermes";
    group = "hermes";
    restartUnits = [ "hermes-backend.service" ];
  };

  users.users.hermes.extraGroups = [ "systemd-journal" ];

  networking.firewall.allowedTCPPorts = [ 9119 ];

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    extraDependencyGroups = [ "messaging" ];
    extraPackages = [
      pkgs.nodejs
      pkgs.gh
    ];
    environment = {
      GIT_AUTHOR_NAME = "Hermes";
      GIT_AUTHOR_EMAIL = "hermes@${vars.defaultDomain}";
      GIT_COMMITTER_NAME = "Hermes";
      GIT_COMMITTER_EMAIL = "hermes@${vars.defaultDomain}";
      TELEGRAM_ALLOWED_CHATS = "";
      TELEGRAM_ALLOWED_USERS = toString vars.telegramUserId;
    };
    environmentFiles = [ config.sops.secrets."hermes-env".path ];
    settings.model.default = "deepseek/deepseek-v4-flash-0731";
    backend = {
      mode = "dashboard";
      host = config.homelab.ip;
      sessionTokenFile = config.sops.secrets."hermes-dashboard-token".path;
    };
    mcpServers.hevy = {
      command = "npx";
      args = [
        "-y"
        "hevy-mcp"
      ];
      env.HEVY_API_KEY = "\${HEVY_API_KEY}";
    };
  };
}
