{ config, ... }:

{
  virtualisation.oci-containers.containers = {
    nginxproxymanager = {
      image = "jc21/nginx-proxy-manager:2.13.3";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=System"
        "-l=homepage.name=Nginx Proxy Manager"
        "-l=homepage.icon=nginx-proxy-manager.svg"
        "-l=homepage.href=http://${config.homelab.ip}:81"
        # "-l=homepage.href=https://jellyseer.${vars.domainName}"
        "-l=homepage.description=Reverse Proxy"

        # "-l=homepage.widget.type=npm"
        # "-l=homepage.widget.url=http://${vars.homelabStaticIp}:81"
        # "-l=homepage.widget.username=TBD in secrets"
        # "-l=homepage.widget.password=TBD in secrets"
      ];
      volumes = [ "npm-data:/data" "npm-letsencrypt:/etc/letsencrypt" ];
      ports = [ "80:80" "81:81" "443:443" ];
      environment = { TZ = config.time.timeZone; };
    };
  };
}
