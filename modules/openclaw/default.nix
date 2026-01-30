{ config, pkgs, nix-openclaw, ... }:

{
  sops.secrets.openclaw-telegram-bot-token = {
    owner = "openclaw";
    group = "openclaw";
    mode = "0400";
  };
  sops.secrets.openclaw-anthropic-api-key = {
    owner = "openclaw";
    group = "openclaw";
    mode = "0400";
  };

  users.groups.openclaw = { };

  users.users.openclaw = {
    isNormalUser = true;
    createHome = true;
    home = "/home/openclaw";
    group = "openclaw";
    shell = pkgs.bashInteractive;
    linger = true;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.openclaw = { ... }: {
      imports = [ nix-openclaw.homeManagerModules.openclaw ];
      home.stateVersion = "25.05";
      programs.home-manager.enable = true;

      systemd.user.services.openclaw-gateway.Service.Environment = [
        "PATH=/run/current-system/sw/bin:/etc/profiles/per-user/openclaw/bin:/nix/var/nix/profiles/default/bin"
      ];

      programs.openclaw = {
        enable = true;
        documents = ../../openclaw-documents;
        firstParty = {
          summarize.enable = false;
          peekaboo.enable = false;
          oracle.enable = false;
          poltergeist.enable = false;
          sag.enable = false;
          camsnap.enable = false;
          gogcli.enable = false;
          bird.enable = false;
          sonoscli.enable = false;
          imsg.enable = false;
        };
        instances.default = {
          enable = true;
          providers.telegram = {
            enable = true;
            botTokenFile = config.sops.secrets.openclaw-telegram-bot-token.path;
            allowFrom = [ 360077892 ];
            groups = {
              "*" = { requireMention = true; };
            };
          };
          providers.anthropic = {
            apiKeyFile = config.sops.secrets.openclaw-anthropic-api-key.path;
          };
        };
      };
    };
  };
}
