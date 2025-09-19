{ lib, vars, ... }:
let inherit (lib) mkIf mkMerge optional;
in {
  virtualisation.oci-containers.containers.qbittorrent = let
    common = {
      image = "lscr.io/linuxserver/qbittorrent:libtorrentv1";
      autoStart = true;
      volumes = [
        "qbittorrent-config:/config"
        "${vars.mediaPath}/torrent:/downloads"
        "${vars.mediaPath}/torrent/incomplete:/incomplete"
      ];
      environment = {
        TZ = vars.timeZone;
        PUID = "1000";
        PGID = "1000";
        WEBUI_PORT = "8080";
        TORRENTING_PORT = "6881";
      };
    };
  in mkMerge [
    common
    (mkIf vars.enableGluetun {
      dependsOn = [ "gluetun" ];
      extraOptions = [
        "--pull=newer"
        "--network=container:gluetun"
        "-l=homepage.group=Media"
        "-l=homepage.name=qBittorrent"
        "-l=homepage.icon=qbittorrent.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:8080"
        "-l=homepage.description=Torrent Client"
        "-l=homepage.widget.type=qbittorrent"
        "-l=homepage.weight=8"
        "-l=homepage.widget.url=http://${vars.homelabStaticIp}:8080"
        "-l=homepage.widget.username=admin"
        "-l=homepage.widget.password={{HOMEPAGE_FILE_QBITTORENT_KEY}}"
      ];
      # Ports managed by Gluetun (mapped in Gluetun container)
    })
    (mkIf (!vars.enableGluetun) {
      # When not using Gluetun, expose ports directly and drop network/dependsOn
      ports = [
        "8080:8080" # web UI
        "6881:6881" # torrent TCP
        "6881:6881/udp" # torrent UDP
      ];
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Media"
        "-l=homepage.name=qBittorrent"
        "-l=homepage.icon=qbittorrent.svg"
        "-l=homepage.href=http://${vars.homelabStaticIp}:8080"
        "-l=homepage.description=Torrent Client"
        "-l=homepage.widget.type=qbittorrent"
        "-l=homepage.weight=8"
        "-l=homepage.widget.url=http://${vars.homelabStaticIp}:8080"
        "-l=homepage.widget.username=admin"
        "-l=homepage.widget.password={{HOMEPAGE_FILE_QBITTORENT_KEY}}"
      ];
    })
  ];
}
