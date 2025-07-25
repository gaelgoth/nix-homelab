{ config, vars, ... }: {
  virtualisation.oci-containers.containers = {
    grafana = {
      image = "grafana/grafana:12.1.0";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=System"
        "-l=homepage.name=Grafana"
        "-l=homepage.icon=grafana.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:3022"
        # "-l=homepage.href=https://jellyseer.${vars.domainName}"
        "-l=homepage.description=Dashboard monitoring"
        "-l=homepage.widget.type=grafana"
        "-l=homepage.widget.url=http://${vars.homelabStaticIp}:3022"
        "-l=homepage.widget.user=admin"
        "-l=homepage.widget.user=TODO"
      ];
      volumes = [ "data-grafana:/var/lib/grafana" ];

      ports = [ "3022:3000" ];
      environment = { TZ = vars.timeZone; };
    };
  };
}
