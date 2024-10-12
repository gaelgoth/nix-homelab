{ config, vars, ... }:

{
  virtualisation.oci-containers.containers = {
    stirlingpdf = {
      image = "frooodle/s-pdf:latest";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Services"
        "-l=homepage.name=Stirling PDF"
        "-l=homepage.icon=stirling-pdf.svg"
        "-l=homepage.href=http://192.168.1.5:3018"
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
        TZ = vars.timeZone;
        DOCKER_ENABLE_SECURITY = "false";
      };
    };
  };
}