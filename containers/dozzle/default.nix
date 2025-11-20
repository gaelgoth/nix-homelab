{ config, ... }: {
  virtualisation.oci-containers.containers = {
    dozzle = {
      image = "amir20/dozzle:v8.14.9";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=System"
        "-l=homepage.name=dozzle"
        "-l=homepage.icon=dozzle.svg"
        "-l=homepage.href=http://${config.homelab.ip}:3024"
        # "-l=homepage.href=https://dozzle.${vars.domainName}"
        "-l=homepage.description=Containers logs"
      ];
      volumes = [ "/var/run/podman/podman.sock:/var/run/docker.sock:ro" ];

      ports = [ "3024:8080" ];
      environment = { TZ = config.time.timeZone; };
    };
  };
}
