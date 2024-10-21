{ config, vars, ... }: {
  virtualisation.oci-containers.containers = {
    dockge = {
      image = "louislam/dockge:1";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=System"
        "-l=homepage.name=dockge - main agent"
        "-l=homepage.icon=dockge.png"
        "-l=homepage.href=http://${vars.homelabStaticIp}:5001"
        # "-l=homepage.href=https://jellyseer.${vars.domainName}"
        "-l=homepage.description=Containers logs"
        "-l=homepage.widget.type=dockge"
        "-l=homepage.widget.url=http://${vars.homelabStaticIp}:5001"
        "-l=homepage.widget.user=admin"
        "-l=homepage.widget.user=TODO"
      ];
      volumes = [
        "dockge-data:/app/data"
        "/mnt/documents/dockge/stacks:/mnt/documents/dockge/stacks"
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];

      ports = [ "5001:5001" ];
      environment = {
        TZ = vars.timeZone;
        DOCKGE_STACKS_DIR = "/mnt/documents/dockge/stacks";
      };
    };
  };
}
