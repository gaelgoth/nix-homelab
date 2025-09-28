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
        # "-l=homepage.href=https://dockge.${vars.domainName}"
        "-l=homepage.description=Containers Manager"
      ];
      volumes = [
        "dockge-data:/app/data"
        "/mnt/documents/dockge/stacks:/mnt/documents/dockge/stacks"
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];

      ports = [ "5001:5001" ];
      environment = {
        TZ = config.time.timeZone;
        DOCKGE_STACKS_DIR = "/mnt/documents/dockge/stacks";
      };
    };
  };
}
