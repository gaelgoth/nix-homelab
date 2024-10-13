{ config, vars, ... }:

{
  virtualisation.oci-containers.containers = {
    speedtest = {
      image = "henrywhitaker3/speedtest-tracker:latest";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Services"
        "-l=homepage.name=Speedtest"
        "-l=homepage.icon=speedtest-tracker.png"
        "-l=homepage.href=http://${vars.homelabStaticIp}:8765"
        # "-l=homepage.href=https://bazarr.${vars.domainName}"
        "-l=homepage.description=Speedtest tracker"
        "-l=homepage.widget.type=speedtest"
        "-l=homepage.widget.url=http://${vars.homelabStaticIp}:8765"
      ];

      volumes = [ "speedtest:/config" ];
      ports = [ "8765:80" ];

      environment = {
        TZ = "Europe/Zurich";
        OOKLA_EULA_GDPR = "true";
      };
      log-driver = "json-file";
    };
  };
}
