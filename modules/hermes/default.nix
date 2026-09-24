{ config, pkgs, ... }:
let vars = import ../../vars.nix;
in {
  sops.secrets."hermes-env" = {
    restartUnits = [ "hermes-agent.service" "hermes-backend.service" ];
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
    extraPackages = [ pkgs.nodejs pkgs.gh ];
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
    settings.fallback_providers = [{
      provider = "openrouter";
      model = "openai/gpt-5.6-sol";
    }];
    settings.delegation = {
      max_iterations = 50;
      model = "z-ai/glm-5.3-flash";
      provider = "openrouter";
    };
    settings.platforms.telegram.extra.dm_topics = [{
      chat_id = vars.telegramUserId;
      # topics = [
      #   {
      #     name = "🧠 Master";
      #     icon_color = 9367192;
      #   } # green
      #   {
      #     name = "🏋🏽 Coach";
      #     icon_color = 13338331;
      #   } # purple
      # ];
    }];
    extraPlugins = [
      (pkgs.fetchFromGitHub {
        owner = "rabilrbl";
        repo = "hermes-brave-search-plugin";
        name = "hermes-brave-search-plugin";
        rev = "4134cbef910c14c63e6b284b0820b30f3811ab47";
        hash = "sha256-XPwjM1cK4Wr43ySIFee0La64C4cbgWxSekriUYwDZVA=";
      })
    ];
    backend = {
      mode = "dashboard";
      host = config.homelab.ip;
      sessionTokenFile = config.sops.secrets."hermes-dashboard-token".path;
    };
    mcpServers.hevy = {
      command = "npx";
      args = [ "-y" "hevy-mcp" ];
      env.HEVY_API_KEY = "\${HEVY_API_KEY}";
    };
    mcpServers.arr = {
      command = "npx";
      args = [ "-y" "mcp-arr-server" ];
      env = {
        SONARR_URL = "http://${config.homelab.ip}:8989";
        SONARR_API_KEY = "\${SONARR_API_KEY}";
        RADARR_URL = "http://${config.homelab.ip}:7878";
        RADARR_API_KEY = "\${RADARR_API_KEY}";
        PROWLARR_URL = "http://${config.homelab.ip}:9696";
        PROWLARR_API_KEY = "\${PROWLARR_API_KEY}";
      };
    };
  };
}
