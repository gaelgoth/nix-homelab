{ config, ... }:
let
  vars = import ../../vars.nix;
in
{
  sops.secrets."hermes-env" = {
    restartUnits = [ "hermes-agent.service" ];
  };

  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    extraDependencyGroups = [ "messaging" ];
    environment = {
      TELEGRAM_ALLOWED_CHATS = "";
      TELEGRAM_ALLOWED_USERS = toString vars.telegramUserId;
    };
    environmentFiles = [ config.sops.secrets."hermes-env".path ];
    settings.model.default = "deepseek/deepseek-v4-flash-0731";
  };
}
