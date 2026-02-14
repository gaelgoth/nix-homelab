{ config, ... }:

{
  virtualisation.oci-containers.containers = {
    cleanuparr = {
      image = "ghcr.io/cleanuparr/cleanuparr:2.5.1";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Media"
        "-l=homepage.name=Cleanuparr"
        "-l=homepage.icon=cleanuparr.png"
        "-l=homepage.href=http://${config.homelab.ip}:11011"
        "-l=homepage.description=Automated cleanup for arr apps and download clients"
        "-l=homepage.weight=10"
      ];
      volumes = [ "cleanuparr-config:/config" ];
      ports = [ "11011:11011" ];
      environment = {
        TZ = config.time.timeZone;
        PUID = "1000";
        PGID = "1000";
        PORT = "11011";
      };
    };
  };
}
