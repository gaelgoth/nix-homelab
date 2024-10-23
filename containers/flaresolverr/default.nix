{ config, vars, ... }: {
  virtualisation.oci-containers.containers = {
    flaresolverr = {
      image = "ghcr.io/flaresolverr/flaresolverr:v3.3.21";
      autoStart = true;
      ports = [ "8191:8191" ];

      environment = {
        LOG_LEVEL = "info";
        LOG_HTML = "false";
        CAPTCHA_SOLVER = "none";
        TZ = vars.timeZone;
      };

      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=System"
        "-l=homepage.name=flaresolverr"
        "-l=homepage.description=Captcha solver proxy"
        "-l=homepage.icon=flaresolverr.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:8191"
      ];

    };
  };
}
