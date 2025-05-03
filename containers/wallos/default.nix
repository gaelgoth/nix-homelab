{ config, vars, ... }:

{
  virtualisation.oci-containers.containers = {
    wallos = {
      image = "bellamy/wallos:3.0.1";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Services"
        "-l=homepage.name=wallos"
        "-l=homepage.icon=wallos.png" # TODO: Set icon
        "-l=homepage.href=http://${vars.homelabStaticIp}:8282"
        # "-l=homepage.href=https://kuma.${vars.domainName}"
        # "-l=homepage.description=Website Monitoring"
        # "-l=homepage.widget.type=uptimekuma"
        # "-l=homepage.widget.url=http://${vars.homelabStaticIp}:3005"
        # "-l=homepage.widget.slug=homelab"
      ];
      volumes = [
        "wallos-db:/var/www/html/db"
        "wallos-logos:/var/www/html/images/uploads/logos"
      ];
      ports = [ "8282:80" ];
      environment = { TZ = vars.timeZone; };
    };
  };
}
