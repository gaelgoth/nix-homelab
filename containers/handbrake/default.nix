{ config, ... }:

{
  virtualisation.oci-containers.containers = {
    handbrake = {
      image = "jlesage/handbrake:v25.12.3";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Services"
        "-l=homepage.name=Handbrake"
        "-l=homepage.icon=handbrake.svg"
        "-l=homepage.href=http://${config.homelab.ip}:5800"
        # "-l=homepage.href=https://jellyseer.${vars.domainName}"
        "-l=homepage.description=Video converter"
      ];
      volumes = [
        "handbrake-config:/config"
        "${config.homelab.mediaPath}/share:/storage"
        "${config.homelab.mediaPath}/share/handbrake/watch:/watch"
        "${config.homelab.mediaPath}/share/handbrake/output:/output"
      ];
      ports = [ "5800:5800" ];
      environment = { TZ = config.time.timeZone; };
    };
  };
}
