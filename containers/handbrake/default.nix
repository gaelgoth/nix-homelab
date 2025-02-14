{ config, vars, ... }:

{
  virtualisation.oci-containers.containers = {
    handbrake = {
      image = "jlesage/handbrake:v25.02.2";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Services"
        "-l=homepage.name=Handbrake"
        "-l=homepage.icon=handbrake.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:5800"
        # "-l=homepage.href=https://jellyseer.${vars.domainName}"
        "-l=homepage.description=Video converter"
      ];
      volumes = [
        "handbrake-config:/config"
        "${vars.mediaPath}/share:/storage"
        "${vars.mediaPath}/share/handbrake/watch:/watch"
        "${vars.mediaPath}/share/handbrake/output:/output"
      ];
      ports = [ "5800:5800" ];
      environment = { TZ = vars.timeZone; };
    };
  };
}
