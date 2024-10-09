{ config, vars, ... }:

{
  virtualisation.oci-containers.containers = {
    qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Media"
        "-l=homepage.name=qBittorrent"
        "-l=homepage.icon=qbittorrent.svg"
        "-l=homepage.href=http://192.168.1.5:8080"
        # "-l=homepage.href=https://bazarr.${vars.domainName}"
        "-l=homepage.description=Torrent Client"
        "-l=homepage.widget.type=qbittorrent"
        "-l=homepage.widget.url=http://192.168.1.5:8080"
        "-l=homepage.widget.username={{HOMEPAGE_FILE_QBITTORENT_USERNAME}}"
        "-l=homepage.widget.password={{HOMEPAGE_FILE_QBITTORENT_PASSWORD}}"
      ];
      volumes = [
        "qbittorrent-config:/config"
        "${vars.mediaPath}/torrent:/downloads"
        "${vars.mediaPath}/torrent/incomplete:/incomplete"
      ];
      ports = [ "8080:8080" "6881:6881" "6881:6881/udp" ];
      environment = { TZ = vars.timeZone; };
    };
  };
  #   TODO: Gluetun
}
