{ config, vars, ... }: {
  virtualisation.oci-containers.containers = {
    dozzle = {
      image = "amir20/dozzle:latest";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=System"
        "-l=homepage.name=dozzle"
        "-l=homepage.icon=dozzle.svg"
        "-l=homepage.href=http://192.168.1.5:3024"
        # "-l=homepage.href=https://jellyseer.${vars.domainName}"
        "-l=homepage.description=Containers logs"
        "-l=homepage.widget.type=dozzle"
        "-l=homepage.widget.url=http://192.168.1.5:3024"
        "-l=homepage.widget.user=admin"
        "-l=homepage.widget.user=TODO"
      ];
      volumes = [ "/var/run/podman/podman.sock:/var/run/docker.sock:ro" ];

      ports = [ "3024:8080" ];
      environment = { TZ = vars.timeZone; };
    };
  };
}