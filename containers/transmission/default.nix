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
        "${vars.mediaPath}/torrent:/downloads"
        "${vars.mediaPath}/torrent/complete/tv-sonarr:/downloads/tv-sonarr"
        "${vars.mediaPath}/torrent/complete/radarr:/downloads/radarr"
        "${vars.mediaPath}/torrent/incomplete:/incomplete"
      ];
      environment = {
        TZ = config.time.timeZone;
        # Align with qBittorrent for consistent ownership on the host
        PUID = "1000";
        PGID = "1000";
        # TRANSMISSION_WEB_HOME = "/flood-for-transmission/"; # Example alt UI
      };
    };
  };
}
