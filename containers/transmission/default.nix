{ config, vars, ... }: {
  virtualisation.oci-containers.containers = {
    transmission = {
      # Using linuxserver.io image for Transmission
      image = "lscr.io/linuxserver/transmission:4.0.6";
      autoStart = true;
      dependsOn = [ "gluetun" ];
      extraOptions = [
        "--pull=newer"
        # Share Gluetun network namespace so traffic goes through VPN
        "--network=container:gluetun"
        # Homepage labels
        "-l=homepage.group=Media"
        "-l=homepage.name=Transmission"
        "-l=homepage.icon=transmission.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:9091"
        "-l=homepage.description=Torrent Client"
        "-l=homepage.weight=9"
        # Widget (no auth by default unless configured, adjust if adding auth)
        "-l=homepage.widget.type=transmission"
        "-l=homepage.widget.url=http://${vars.homelabStaticIp}:9091"
      ];
      volumes = [
        "transmission-config:/config"
        # Completed + active downloads
        "${vars.mediaPath}/torrent:/downloads"
        # Optional watch folder for .torrent files
        # "${vars.mediaPath}/torrent/watch:/watch"
        # Optional incomplete directory (Transmission supports it when enabled in settings.json)
        "${vars.mediaPath}/torrent/incomplete:/incomplete"
      ];
      # Ports exposed via Gluetun (9091, 51413 TCP/UDP) so none mapped here directly.
      environment = {
        TZ = vars.timeZone;
        # PUID = "1000"; # Uncomment & adjust if needed for permissions
        # PGID = "1000";
        # TRANSMISSION_WEB_HOME = "/flood-for-transmission/"; # Example alt UI
      };
    };
  };
}
