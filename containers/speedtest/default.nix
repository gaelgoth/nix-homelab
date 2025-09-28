{ config, ... }:

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
        "-l=homepage.href=http://${config.homelab.ip}:8765"
        # "-l=homepage.href=https://bazarr.${vars.domainName}"
        "-l=homepage.description=Speedtest tracker"
        "-l=homepage.widget.type=speedtest"
        "-l=homepage.widget.url=http://${config.homelab.ip}:8765"
      ];

      volumes = [ "speedtest:/config" ];
      ports = [ "8765:80" ];

      environment = {
        TZ = config.time.timeZone;
        OOKLA_EULA_GDPR = "true";
      };
      log-driver = "json-file";
    };
  };
}
