{ config, vars, ... }:

{
  virtualisation.oci-containers.containers = {
    jellyseerr = {
      image = "fallenbagel/jellyseerr:latest";
      autoStart = true;
      extraOptions = [
        # "--pull=newer"
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
        # "--pull=newer"
      ];
      volumes = [ "prowlarr-config:/config" ];
      ports = [ "9696:9696" ];
      environment = { TZ = vars.timeZone; };
    };
    sonarr = {
      image = "lscr.io/linuxserver/sonarr:latest";
      autoStart = true;
      extraOptions = [
        # "--pull=newer"
      ];
      volumes = [ "sonarr-config:/config" "${vars.mediaPath}/Shows:/tv" ];
      ports = [ "8989:8989" ];
      environment = { TZ = vars.timeZone; };
    };
  };
}
