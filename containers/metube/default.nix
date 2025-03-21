{ config, vars, ... }:

{
  virtualisation.oci-containers.containers = {
    metube = {
      image = "ghcr.io/alexta69/metube:2024-10-23";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Services"
        "-l=homepage.name=meTube"
        "-l=homepage.icon=metube.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:3024"
        # "-l=homepage.href=https://jellyseer.${vars.domainName}"
        "-l=homepage.description=Streaming downloader (Youtube, SoundCloud, Reddit,...)"

      ];

      volumes = [ "${vars.mediaPath}/downloads:/downloads" ];
      ports = [ "3025:8081" ];
      environment = { TZ = vars.timeZone; };
    };
  };
}
