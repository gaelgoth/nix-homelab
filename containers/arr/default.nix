{ config, vars, ... }:

{
  virtualisation.oci-containers.containers = {
    jellyseerr = {
      image = "fallenbagel/jellyseerr:1.9.2";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Media"
        "-l=homepage.name=Jellyseerr"
        "-l=homepage.icon=jellyseerr.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:5055"
        # "-l=homepage.href=https://jellyseer.${vars.domainName}"
        "-l=homepage.description=Discover and request media"
        "-l=homepage.widget.type=jellyseerr"
        "-l=homepage.widget.url=http://${vars.homelabStaticIp}:5055"
        "-l=homepage.widget.key={{HOMEPAGE_FILE_JELLYSEERR_KEY}}"
      ];
      volumes = [ "jellyseerr-config:/app/config" ];
      ports = [ "5055:5055" ];
      environment = {
        TZ = vars.timeZone;
        LOG_LEVEL = "debug";
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
        "-l=homepage.href=http://${vars.homelabStaticIp}:9696"
        # "-l=homepage.href=https://prowlarr.${vars.domainName}"
        "-l=homepage.description=Manage RSS fetch"
        "-l=homepage.widget.type=prowlarr"
        "-l=homepage.widget.fields=['numberOfGrabs', 'numberOfQueries']"
        "-l=homepage.widget.url=http://${vars.homelabStaticIp}:9696"
        "-l=homepage.widget.key={{HOMEPAGE_FILE_PROWLARR_KEY}}"
      ];
      volumes = [ "prowlarr-config:/config" ];
      ports = [ "9696:9696" ];
      environment = { TZ = vars.timeZone; };
    };

    sonarr = {
      image = "lscr.io/linuxserver/sonarr:latest";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Media"
        "-l=homepage.name=Sonarr"
        "-l=homepage.icon=sonarr.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:8989"
        # "-l=homepage.href=https://sonarr.${vars.domainName}"
        "-l=homepage.description=Monitor RSS for new episodes of TV shows"
        "-l=homepage.widget.enableQueue=true"
        "-l=homepage.widget.type=sonarr"
        "-l=homepage.widget.url=http://${vars.homelabStaticIp}:8989"
        "-l=homepage.widget.key={{HOMEPAGE_FILE_SONARR_KEY}}"
      ];
      volumes = [ "sonarr-config:/config" "${vars.mediaPath}/Shows:/tv" ];
      ports = [ "8989:8989" ];
      environment = { TZ = vars.timeZone; };
    };

    radarr = {
      image = "lscr.io/linuxserver/radarr:latest";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Media"
        "-l=homepage.name=Radarr"
        "-l=homepage.icon=radarr.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:7878"
        # "-l=homepage.href=https://radarr.${vars.domainName}"
        "-l=homepage.description=Monitor RSS for new episodes of TV shows"
        "-l=homepage.widget.enableQueue=true"
        "-l=homepage.widget.type=radarr"
        "-l=homepage.widget.url=http://${vars.homelabStaticIp}:7878"
        "-l=homepage.widget.key={{HOMEPAGE_FILE_RADARR_KEY}}"
      ];
      volumes = [ "radarr-config:/config" "${vars.mediaPath}/Shows:/tv" ];
      ports = [ "7878:7878" ];
      environment = { TZ = vars.timeZone; };
    };

    readarr = {
      image = "lscr.io/linuxserver/readarr:develop";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Media"
        "-l=homepage.name=Readarr"
        "-l=homepage.icon=readarr.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:8787"
        # "-l=homepage.href=https://readarr.${vars.domainName}"
        "-l=homepage.description=Monitor RSS for EBooks"
        "-l=homepage.widget.enableQueue=true"
        "-l=homepage.widget.type=readarr"
        "-l=homepage.widget.url=http://${vars.homelabStaticIp}:8787"
        "-l=homepage.widget.key={{HOMEPAGE_FILE_READARR_KEY}}"
      ];
      volumes = [
        "readarr-config:/config"
        "${vars.mediaPath}/Books:/books"
        "${vars.mediaPath}/torrent:/downloads"
      ];
      ports = [ "8787:8787" ];
      environment = { TZ = vars.timeZone; };
    };

    bazarr = {
      image = "lscr.io/linuxserver/bazarr:latest";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Media"
        "-l=homepage.name=Bazarr"
        "-l=homepage.icon=bazarr.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:6767"
        # "-l=homepage.href=https://bazarr.${vars.domainName}"
        "-l=homepage.description=Subtitle management"
        "-l=homepage.widget.type=bazarr"
        "-l=homepage.widget.url=http://${vars.homelabStaticIp}:6767"
        "-l=homepage.widget.key={{HOMEPAGE_FILE_BAZARR_KEY}}"
      ];
      volumes = [
        "bazarr-config:/config"
        "${vars.mediaPath}/Movies:/movies"
        "${vars.mediaPath}/Shows:/tv"
      ];
      ports = [ "6767:6767" ];
      environment = { TZ = vars.timeZone; };
    };
  };
}
