{ config, vars, pkgs, ... }:
let
  #   directories = [
  #     "${vars.serviceConfigRoot}/homepage"
  #     "${vars.serviceConfigRoot}/homepage/config"
  #   ];

  settingsFormat = pkgs.formats.yaml { };
  glanceSettings = {
    docker = settingsFormat.generate "docker.yaml" (import ./docker.nix);
    glance = pkgs.writeTextFile {
      name = "glance.yml";
      text = builtins.readFile ./glance.yml;
    };
  };
in {

  #   sops.secrets.adguardhome-password = { };
  #   sops.secrets.bazarr-api-key = { };
  #   sops.secrets.changedetection-api-key = { };
  #   sops.secrets.grafana-password = { };
  #   sops.secrets.jellyfin-api-key = { };
  #   sops.secrets.jellyseerr-api-key = { };
  #   sops.secrets.prowlarr-api-key = { };
  #   sops.secrets.qbittorrent-admin-password = { };
  #   sops.secrets.radarr-api-key = { };
  #   sops.secrets.sonarr-api-key = { };
  #   sops.secrets.synology-dsm-service-account-password = { };
  #   sops.secrets.watchtower-api-key = { };

  virtualisation.oci-containers = {
    containers = {
      glance = {
        image = "glanceapp/glance:v0.8.3";
        autoStart = true;
        extraOptions = [
          "--pull=newer"
          "-l=homepage.group=Services"
          "-l=homepage.name=Glance"
          "-l=homepage.icon=glance.svg"
          "-l=homepage.href=http://${vars.homelabStaticIp}:3027"
        ];
        volumes = [
          "glance-config:/app/config"
          "${glanceSettings.docker}:/app/config/docker.yml"
          "${glanceSettings.glance}:/app/config/glance.yml"

          #   "${config.sops.secrets.adguardhome-password.path}:/app/config/adguardhome.key"
          #   "${config.sops.secrets.changedetection-api-key.path}:/app/config/changedetection.key"
          #   "${config.sops.secrets.bazarr-api-key.path}:/app/config/bazarr.key"
          #   "${config.sops.secrets.grafana-password.path}:/app/config/grafana.key"
          #   "${config.sops.secrets.jellyfin-api-key.path}:/app/config/jellyfin.key"
          #   "${config.sops.secrets.jellyseerr-api-key.path}:/app/config/jellyseer.key"
          #   "${config.sops.secrets.prowlarr-api-key.path}:/app/config/prowlarr.key"
          #   "${config.sops.secrets.qbittorrent-admin-password.path}:/app/config/qbittorrent-admin-password.key"
          #   "${config.sops.secrets.radarr-api-key.path}:/app/config/radarr.key"
          #   "${config.sops.secrets.sonarr-api-key.path}:/app/config/sonarr.key"
          #   "${config.sops.secrets.synology-dsm-service-account-password.path}:/app/config/synology.key"
          #   "${config.sops.secrets.watchtower-api-key.path}:/app/config/watchtower.key"

          "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
        ];
        ports = [ "3027:8080" ];
        environment = {
          TZ = vars.timeZone;

          UPTIME_KUMA_URL = "https://kuma.homelab.gothuey.dev";
          UPTIME_KUMA_STATUS_SLUG = "containers";

          #   HOMEPAGE_FILE_ADGUARDHOME_KEY = "/app/config/adguardhome.key";
          #   HOMEPAGE_FILE_CHANGEDETECTION_KEY = "/app/config/changedetection.key";
          #   HOMEPAGE_FILE_BAZARR_KEY = "/app/config/bazarr.key";
          #   HOMEPAGE_FILE_GRAFANA_KEY = "/app/config/grafana.key";
          #   HOMEPAGE_FILE_JELLYFIN_KEY = "/app/config/jellyfin.key";
          #   HOMEPAGE_FILE_JELLYSEERR_KEY = "/app/config/jellyseer.key";
          #   HOMEPAGE_FILE_PROWLARR_KEY = "/app/config/prowlarr.key";
          #   HOMEPAGE_FILE_RADARR_KEY = "/app/config/radarr.key";
          #   HOMEPAGE_FILE_SONARR_KEY = "/app/config/sonarr.key";
          #   HOMEPAGE_FILE_QBITTORENT_KEY =
          #     "/app/config/qbittorrent-admin-password.key";
          #   HOMEPAGE_FILE_SYNOLOGY_KEY = "/app/config/synology.key";
          #   HOMEPAGE_FILE_WATCHTOWER_KEY = "/app/config/watchtower.key";
        };
        # environmentFiles = [ config.sops.secrets.sonarr-api-key.path ];
      };
    };
  };
}
