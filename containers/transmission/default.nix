{ lib, vars, ... }:
let inherit (lib) mkIf mkMerge;
in {
  virtualisation.oci-containers.containers.transmission = let
    common = {
      image = "lscr.io/linuxserver/transmission:4.0.6";
      autoStart = true;
      volumes = [
        "transmission-config:/config"
        "${vars.mediaPath}/torrent:/downloads"
        # "${vars.mediaPath}/torrent/watch:/watch" # optional watch folder
        "${vars.mediaPath}/torrent/incomplete:/incomplete"
      ];
      environment = { TZ = vars.timeZone; };
    };
    labels = [
      "-l=homepage.group=Media"
      "-l=homepage.name=Transmission"
      "-l=homepage.icon=transmission.svg"
      "-l=homepage.href=http://${vars.homelabStaticIp}:9091"
      "-l=homepage.description=Torrent Client"
      "-l=homepage.weight=9"
      "-l=homepage.widget.type=transmission"
      "-l=homepage.widget.url=http://${vars.homelabStaticIp}:9091"
    ];
  in mkMerge [
    common
    (mkIf vars.enableGluetun {
      dependsOn = [ "gluetun" ];
      extraOptions = [ "--pull=newer" "--network=container:gluetun" ] ++ labels;
      # Ports managed via Gluetun
    })
    (mkIf (!vars.enableGluetun) {
      ports = [
        "9091:9091" # web UI
        "51413:51413" # peer TCP
        "51413:51413/udp" # peer UDP
      ];
      extraOptions = [ "--pull=newer" ] ++ labels;
    })
  ];
}
