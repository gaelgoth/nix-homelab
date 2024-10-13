{ config, vars, ... }:

{
  virtualisation.oci-containers.containers = {
    pairdrop = {
      image = "lscr.io/linuxserver/pairdrop:latest";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Services"
        "-l=homepage.name=PairDrop"
        "-l=homepage.icon=snapdrop.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:3000"
        # "-l=homepage.href=https://jellyseer.${vars.domainName}"
        "-l=homepage.description=Send files over the local network"
      ];
      ports = [ "3021:3000" ];
      environment = {
        TZ = vars.timeZone;
        RATE_LIMIT = "false";
        WS_FALLBACK = "false"; # optional
        RTC_CONFIG = ""; # optional
      };
    };
  };
}
