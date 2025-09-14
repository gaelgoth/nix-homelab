    { config, vars, ... }:
    let
      joalPort = 8445;
      uiPrefix = "joal";
      secretToken = "CHANGE_ME_SECURE_TOKEN";
      enableIframe = false;
    in {
      virtualisation.oci-containers.containers = {
        joal = {
          image = "anthonyraymond/joal:latest";
          autoStart = true;
          extraOptions = [
            "--pull=newer"
            "-l=homepage.group=Media"
            "-l=homepage.name=JOAL"
            "-l=homepage.icon=mdi-arrow-top-left"
            "-l=homepage.href=http://${vars.homelabStaticIp}:${toString joalPort}/${uiPrefix}/ui/#/"
          ];

          cmd = [
            "--joal-conf=/data"
            "--spring.main.web-environment=true"
            "--server.port=${toString joalPort}"
            "--joal.ui.path.prefix=${uiPrefix}"
            "--joal.ui.secret-token=${secretToken}"
          ] ++ (if enableIframe then [ "--joal.iframe.enabled=true" ] else []);

          # Mount local (Nix-store) config + clients as read-only; keep torrents writable via named volume.
          # ./config.json and ./clients refer to this directory (added to store at build time).
          # 'joal-torrents' named volume persists dynamic torrent additions between rebuilds.
          volumes = [
            "${./config.json}:/data/config.json:ro"
            "${./clients}:/data/clients:ro"
            "joal-torrents:/data/torrents"
          ];

          # Expose same port outside for simplicity
          ports = [ "${toString joalPort}:${toString joalPort}" ];

          environment = {
            TZ = vars.timeZone;
          };
        };
      };
    }
