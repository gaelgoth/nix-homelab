{ config, ... }: {
  virtualisation.oci-containers.containers = {
    flaresolverr = {
      # image = "ghcr.io/flaresolverr/flaresolverr:v3.4.6";
      image = "21hsmw/flaresolverr:nodriver"; # NOTE: Temporary fix for prowlarr
      autoStart = true;
      ports = [ "8191:8191" ];

      environment = {
        LOG_LEVEL = "info";
        LOG_HTML = "false";
        CAPTCHA_SOLVER = "none";
        TZ = config.time.timeZone;
      };

      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=System"
        "-l=homepage.name=flaresolverr"
        "-l=homepage.description=Captcha solver proxy"
        "-l=homepage.icon=flaresolverr.svg"
        "-l=homepage.href=http://${config.homelab.ip}:8191"
      ];

    };
  };
}
