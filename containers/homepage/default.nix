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

  sops.secrets.changedetection-api-key = { };
  sops.secrets.bazarr-api-key = { };
  sops.secrets.grafana-password = { };
  sops.secrets.jellyfin-api-key = { };
  sops.secrets.jellyseerr-api-key = { };
  sops.secrets.prowlarr-api-key = { };
  sops.secrets.qbittorrent-admin-password = { };
  sops.secrets.radarr-api-key = { };
  sops.secrets.sonarr-api-key = { };

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

          "${config.sops.secrets.changedetection-api-key.path}:/app/config/changedetection.key"
          "${config.sops.secrets.bazarr-api-key.path}:/app/config/bazarr.key"
          "${config.sops.secrets.grafana-password.path}:/app/config/grafana.key"
          "${config.sops.secrets.jellyfin-api-key.path}:/app/config/jellyfin.key"
          "${config.sops.secrets.jellyseerr-api-key.path}:/app/config/jellyseer.key"
          "${config.sops.secrets.prowlarr-api-key.path}:/app/config/prowlarr.key"
          "${config.sops.secrets.qbittorrent-admin-password.path}:/app/config/qbittorrent-admin-password.key"
          "${config.sops.secrets.radarr-api-key.path}:/app/config/radarr.key"
          "${config.sops.secrets.sonarr-api-key.path}:/app/config/sonarr.key"
          "${config.sops.secrets.watchtower-api-key.path}:/app/config/watchtower.key"

          "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
        ];
        ports = [ "3001:3000" ];
        environment = {
          TZ = vars.timeZone;

          HOMEPAGE_FILE_CHANGEDETECTION_KEY = "/app/config/changedetection.key";
          HOMEPAGE_FILE_BAZARR_KEY = "/app/config/bazarr.key";
          HOMEPAGE_FILE_GRAFANA_KEY = "/app/config/grafana.key";
          HOMEPAGE_FILE_JELLYFIN_KEY = "/app/config/jellyfin.key";
          HOMEPAGE_FILE_JELLYSEERR_KEY = "/app/config/jellyseer.key";
          HOMEPAGE_FILE_PROWLARR_KEY = "/app/config/prowlarr.key";
          HOMEPAGE_FILE_RADARR_KEY = "/app/config/radarr.key";
          HOMEPAGE_FILE_SONARR_KEY = "/app/config/sonarr.key";
          HOMEPAGE_FILE_QBITTORENT_KEY =
            "/app/config/qbittorrent-admin-password.key";
          HOMEPAGE_FILE_WATCHTOWER_KEY = "/app/config/watchtower.key";
        };
        environmentFiles = [ config.sops.secrets.sonarr-api-key.path ];
      };
    };
  };
}
