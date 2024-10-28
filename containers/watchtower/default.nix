{ config, vars, ... }:

{
  virtualisation.oci-containers.containers = {
    watchtower = {
      image = "containrrr/watchtower:v1.7.1";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=System"
        "-l=homepage.name=Watchtower"
        "-l=homepage.icon=watchtower.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:3024"
        # "-l=homepage.href=https://bazarr.${vars.domainName}"
        "-l=homepage.description=Auto-update latest containers tag"
        # "-l=homepage.widget.type=watchtower"
        # "-l=homepage.widget.url=http://${vars.homelabStaticIp}:3003"
        # "-l=homepage.widget.key=TBD"
      ];
      volumes = [

        "WATCHTOWER_CLEANUP=true"
        "WATCHTOWER_HTTP_API_METRICS: TBD"
        "WATCHTOWER_SCHEDULE: 0 3 * * *" # Every day at 3 AM
        "WATCHTOWER_TRACE: true"
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];
      ports = [ "3003:8080" ];
      environment = { TZ = vars.timeZone; };
    };
  };
}
