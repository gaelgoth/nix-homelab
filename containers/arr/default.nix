{ config, ... }:

{
  sops.secrets.ygege-env = {
    sopsFile = ../../secrets/secrets.yaml;
  };

  virtualisation.oci-containers.containers = {
    jellyseerr = {
      image = "fallenbagel/jellyseerr:2.7.3";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Media"
        "-l=homepage.name=Jellyseerr"
        "-l=homepage.icon=jellyseerr.svg"
        # "-l=homepage.href=http://${config.homelab.ip}:5055"
        "-l=homepage.href=https://jellyseerr.${config.homelab.domain}"
        "-l=homepage.description=Discover and request media"
        "-l=homepage.weight=2"
        "-l=homepage.widget.type=jellyseerr"
        "-l=homepage.widget.url=http://${config.homelab.ip}:5055"
        "-l=homepage.widget.key={{HOMEPAGE_FILE_JELLYSEERR_KEY}}"
      ];
      volumes = [ "jellyseerr-config:/app/config" ];
      ports = [ "5055:5055" ];
      environment = {
        TZ = config.time.timeZone;
        LOG_LEVEL = "info";
      };
    };

    prowlarr = {
      image = "lscr.io/linuxserver/prowlarr:develop";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Media"
        "-l=homepage.name=Prowlarr"
        "-l=homepage.icon=prowlarr.svg"
        # "-l=homepage.href=http://${config.homelab.ip}:9696"
        "-l=homepage.href=https://prowlarr.${config.homelab.domain}"
        "-l=homepage.description=Manage RSS fetch"
        "-l=homepage.weight=3"
        "-l=homepage.widget.type=prowlarr"
        "-l=homepage.widget.url=http://${config.homelab.ip}:9696"
        "-l=homepage.widget.key={{HOMEPAGE_FILE_PROWLARR_KEY}}"
      ];
      volumes = [
        "prowlarr-config:/config"
        "${./ygege.yml}:/config/Definitions/Custom/ygege.yml:ro"
      ];
      ports = [ "9696:9696" ];
      environment = {
        TZ = config.time.timeZone;
      };
    };

    ygege = {
      image = "uwucode/ygege:latest";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Media"
        "-l=homepage.name=Ygege"
        "-l=homepage.icon=ygege.svg"
        "-l=homepage.href=http://${config.homelab.ip}:8715"
        "-l=homepage.description=YGG indexer bridge"
        "-l=homepage.weight=4"
      ];
      volumes = [ "ygege-config:/config" ];
      ports = [ "8715:8715" ];
      environmentFiles = [ config.sops.secrets.ygege-env.path ];
      environment = {
        TZ = config.time.timeZone;
        LOG_LEVEL = "info";
        BIND_IP = "0.0.0.0";
        BIND_PORT = "8715";
      };
    };

    sonarr = {
      image = "lscr.io/linuxserver/sonarr:latest";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Media"
        "-l=homepage.name=Sonarr"
        "-l=homepage.icon=sonarr.svg"
        # "-l=homepage.href=http://${config.homelab.ip}:8989"
        "-l=homepage.href=https://sonarr.${config.homelab.domain}"
        "-l=homepage.description=Monitor RSS for new episodes of TV shows"
        "-l=homepage.weight=4"
        "-l=homepage.widget.enableQueue=true"
        "-l=homepage.widget.type=sonarr"
        "-l=homepage.widget.url=http://${config.homelab.ip}:8989"
        "-l=homepage.widget.key={{HOMEPAGE_FILE_SONARR_KEY}}"
      ];
      volumes = [
        "sonarr-config:/config"
        "${config.homelab.mediaPath}/Shows:/tv"
        "${config.homelab.mediaPath}/torrent:/downloads"
        "${config.homelab.mediaPath}/torrent/complete/tv-sonarr:/downloads/tv-sonarr"
      ];
      ports = [ "8989:8989" ];
      environment = {
        TZ = config.time.timeZone;
      };
    };

    radarr = {
      image = "lscr.io/linuxserver/radarr:latest";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Media"
        "-l=homepage.name=Radarr"
        "-l=homepage.icon=radarr.svg"
        "-l=homepage.href=http://${config.homelab.ip}:7878"
        "-l=homepage.href=https://radarr.${config.homelab.domain}"
        "-l=homepage.description=Monitor RSS for new episodes of TV shows"
        "-l=homepage.weight=5"
        "-l=homepage.widget.enableQueue=true"
        "-l=homepage.widget.type=radarr"
        "-l=homepage.widget.url=http://${config.homelab.ip}:7878"
        "-l=homepage.widget.key={{HOMEPAGE_FILE_RADARR_KEY}}"
      ];
      volumes = [
        "radarr-config:/config"
        "${config.homelab.mediaPath}/Movies:/Movies"
        "${config.homelab.mediaPath}/torrent:/downloads"
        "${config.homelab.mediaPath}/torrent/complete/radarr:/downloads/radarr"
      ];
      ports = [ "7878:7878" ];
      environment = {
        TZ = config.time.timeZone;
      };
    };

    bazarr = {
      image = "lscr.io/linuxserver/bazarr:latest";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Media"
        "-l=homepage.name=Bazarr"
        "-l=homepage.icon=bazarr.svg"
        # "-l=homepage.href=http://${config.homelab.ip}:6767"
        "-l=homepage.href=https://bazarr.${config.homelab.domain}"
        "-l=homepage.description=Subtitle management"
        "-l=homepage.weight=7"
        "-l=homepage.widget.type=bazarr"
        "-l=homepage.widget.url=http://${config.homelab.ip}:6767"
        "-l=homepage.widget.key={{HOMEPAGE_FILE_BAZARR_KEY}}"
      ];
      volumes = [
        "bazarr-config:/config"
        "${config.homelab.mediaPath}/Movies:/movies"
        "${config.homelab.mediaPath}/Shows:/tv"
      ];
      ports = [ "6767:6767" ];
      environment = {
        TZ = config.time.timeZone;
      };
    };
  };
}
