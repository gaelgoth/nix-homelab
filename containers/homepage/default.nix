{ config, vars, pkgs, ... }:
let
  #   directories = [
  #     "${vars.serviceConfigRoot}/homepage"
  #     "${vars.serviceConfigRoot}/homepage/config"
  #   ];

  settingsFormat = pkgs.formats.yaml { };
  homepageSettings = {
    docker = settingsFormat.generate "docker.yaml" (import ./docker.nix);
    services = pkgs.writeTextFile {
      name = "services.yaml";
      text = builtins.readFile ./services.yaml;
    };
    settings = pkgs.writeTextFile {
      name = "settings.yaml";
      text = builtins.readFile ./settings.yaml;
    };
    bookmarks =
      settingsFormat.generate "bookmarks.yaml" (import ./bookmarks.nix);
    widgets = pkgs.writeTextFile {
      name = "widgets.yaml";
      text = builtins.readFile ./widgets.yaml;
    };
  };
  homepageCustomCss = pkgs.writeTextFile {
    name = "custom.css";
    text = builtins.readFile ./custom.css;
  };
in {

  environment.systemPackages = with pkgs; [ glances ];

  networking.firewall.allowedTCPPorts = [ 61208 ];

  systemd.services.glances = {
    description = "Glances";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.glances}/bin/glances -w";
      Type = "simple";
    };
  };

  sops.secrets.sonarr-api-key = { };
  sops.secrets.qbittorrent-admin-password = { };

  virtualisation.oci-containers = {
    containers = {
      homepage = {
        image = "ghcr.io/gethomepage/homepage:v0.9.11";
        autoStart = true;
        extraOptions = [ "--pull=newer" ];
        volumes = [
          "homepage-config:/app/config"
          "${homepageSettings.docker}:/app/config/docker.yaml"
          "${homepageSettings.bookmarks}:/app/config/bookmarks.yaml"
          "${homepageSettings.services}:/app/config/services.yaml"
          "${homepageSettings.settings}:/app/config/settings.yaml"
          "${homepageSettings.widgets}:/app/config/widgets.yaml"
          "${homepageCustomCss}:/app/config/custom.css"
          "${config.sops.secrets.sonarr-api-key.path}:/app/config/sonarr.key"
          "${config.sops.secrets.qbittorrent-admin-password.path}:/app/config/qbittorrent-admin-password.key"

          "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
        ];
        ports = [ "3001:3000" ];
        environment = {
          TZ = vars.timeZone;
          #   HOMEPAGE_FILE_SONARR_KEY = "/app/config/sonarr.key";
          #   HOMEPAGE_FILE_RADARR_KEY = "/app/config/radarr.key";
          #   HOMEPAGE_FILE_JELLYFIN_KEY = "/app/config/jellyfin.key";
          HOMEPAGE_FILE_SONARR_KEY = "/app/config/sonarr.key";
          HOMEPAGE_FILE_QBITTORENT_KEY =
            "/app/config/qbittorrent-admin-password.key";

        };
        environmentFiles = [ config.sops.secrets.sonarr-api-key.path ];
      };
    };
  };
}
