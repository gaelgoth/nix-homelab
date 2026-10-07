{ config, ... }:
let serviceName = "${config.virtualisation.oci-containers.backend}-syncthing";
in {
  networking.firewall.allowedTCPPorts = [ 8384 22000 ];
  networking.firewall.allowedUDPPorts = [ 22000 21027 ];

  virtualisation.oci-containers.containers = {
    syncthing = {
      image = "syncthing/syncthing:2.1.6";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "--network=host"
        "-l=homepage.group=Services"
        "-l=homepage.name=Syncthing"
        "-l=homepage.icon=syncthing.svg"
        "-l=homepage.href=http://${config.homelab.ip}:8384"
        "-l=homepage.description=File synchronization"
        "-l=homepage.widget.type=syncthing"
        "-l=homepage.widget.url=http://${config.homelab.ip}:8384"
        "-l=homepage.widget.key={{HOMEPAGE_FILE_SYNCTHING_KEY}}"
      ];
      volumes = [
        "syncthing-config:/var/syncthing"
        "${config.homelab.mediaPath}/syncthing:/data"
      ];
      environment = {
        TZ = config.time.timeZone;
        PUID = "1000";
        PGID = "1000";
        STGUIADDRESS = "0.0.0.0:8384";
      };
    };
  };

  systemd.services.${serviceName}.serviceConfig.RequiresMountsFor =
    [ config.homelab.mediaPath ];
}
