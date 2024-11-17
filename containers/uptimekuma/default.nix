{ config, vars, ... }:

{
  virtualisation.oci-containers.containers = {
    uptimekuma = {
      image = "louislam/uptime-kuma:1";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Services"
        "-l=homepage.name=uptime-kuma"
        "-l=homepage.icon=uptime-kuma.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:3005"
        # "-l=homepage.href=https://kuma.${vars.domainName}"
        # "-l=homepage.description=Website Monitoring"
        # "-l=homepage.widget.type=uptimekuma"
        # "-l=homepage.widget.url=http://${vars.homelabStaticIp}:3005"
        # "-l=homepage.widget.slug=homelab"
      ];
      volumes = [
        "uptimekuma-data:/app/data"
        "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
      ];
      ports = [ "3005:3001" ];
      environment = { TZ = vars.timeZone; };
    };
  };
}
