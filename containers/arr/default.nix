{ config, vars, ... }:

{
  virtualisation.oci-containers.containers = {
    speedtest = {
      image = "henrywhitaker3/speedtest-tracker:latest";
      autoStart = true;
      ports = [ "8765:80" ];
      volumes = [ "speedtest:/config" ];
      environment = {
        TZ = "Europe/Zurich";
        OOKLA_EULA_GDPR = "true";
      };
      log-driver = "json-file";
    };
  };
}
