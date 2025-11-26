{ config, ... }:

{
  virtualisation.oci-containers.containers = {
    stirlingpdf = {
      image = "frooodle/s-pdf:1.6.0";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Services"
        "-l=homepage.name=Stirling PDF"
        "-l=homepage.icon=stirling-pdf.svg"
        "-l=homepage.href=http://${config.homelab.ip}:3018"
        # "-l=homepage.href=https://jellyseer.${vars.domainName}"
        "-l=homepage.description=Perform various operations on PDF files"
      ];
      volumes = [
        "stirling-training-data:/usr/share/tessdata"
        "stirling-config:/configs"
        "stirling-logs:/logs"
      ];
      ports = [ "3018:8080" ];
      environment = {
        TZ = config.time.timeZone;
        DOCKER_ENABLE_SECURITY = "false";
      };
    };
  };
}
