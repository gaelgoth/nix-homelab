{ config, vars, ... }:

{
  virtualisation.oci-containers.containers = {
    jellyfin = {
      image = "jellyfin/jellyfin:latest";
      autoStart = true;
      extraOptions = [
        # "--pull=newer"
        # "--device=/dev/dri:/dev/dri"
      ];

      volumes = [
        "jellyfin-config:/config"
        "jellyfin-cache:/cache"
        "/mnt/media:/media"
      ];
      ports = [ "8096:8096" ];
      environment = {
        TZ = "Europe/Zurich";
        # PUID = "994";
        # UMASK = "002";
      };
    };
  };
}
