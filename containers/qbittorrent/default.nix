{ config, vars, ... }:

{
  virtualisation.oci-containers.containers = {
    qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      autoStart = true;
      dependsOn = [ "gluetun" ];
      extraOptions = [
        "--pull=newer"
        "--network=container:gluetun"
        "-l=homepage.group=Media"
        "-l=homepage.name=qBittorrent"
        "-l=homepage.icon=qbittorrent.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:8080"
        # "-l=homepage.href=https://bazarr.${vars.domainName}"
        "-l=homepage.description=Torrent Client"
        "-l=homepage.widget.type=qbittorrent"
        "-l=homepage.weight=8"

        "-l=homepage.widget.url=http://${vars.homelabStaticIp}:8080"
        "-l=homepage.widget.username=admin"
        "-l=homepage.widget.password={{HOMEPAGE_FILE_QBITTORENT_KEY}}"
      ];
      volumes = [
        "qbittorrent-config:/config"
        "${vars.mediaPath}/torrent:/downloads"
        "${vars.mediaPath}/torrent/incomplete:/incomplete"
      ];
      # Ports are managed by Gluetun. See Gluetun container config for port mapping.
      environment = { TZ = vars.timeZone; };
    };
  };
  #   TODO: Gluetun
}
