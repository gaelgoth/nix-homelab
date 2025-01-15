{ config, vars, ... }: {
  virtualisation.oci-containers.containers = {
    dozzle = {
      image = "amir20/dozzle:v8.10.4";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=System"
        "-l=homepage.name=dozzle"
        "-l=homepage.icon=dozzle.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:3024"
        # "-l=homepage.href=https://dozzle.${vars.domainName}"
        "-l=homepage.description=Containers logs"
      ];
      volumes = [ "/var/run/podman/podman.sock:/var/run/docker.sock:ro" ];

      ports = [ "3024:8080" ];
      environment = { TZ = vars.timeZone; };
    };
  };
}
