# Known issue on container recreation: https://github.com/containrrr/watchtower/issues/1060#issuecomment-2415846223

{ config, vars, pkgs, ... }:
let
in {
  sops.secrets.watchtower-api-key = { };

  virtualisation.oci-containers = {
    containers = {
      watchtower = {
        image = "containrrr/watchtower:1.7.1";
        autoStart = true;
        extraOptions = [
          "--pull=newer"
          "-l=homepage.group=System"
          "-l=homepage.name=Watchtower"
          "-l=homepage.icon=watchtower.svg"
          "-l=homepage.href=http://${vars.homelabStaticIp}:3024"
          # "-l=homepage.href=https://bazarr.${vars.domainName}"
          "-l=homepage.description=Auto-update latest containers tag"
          "-l=homepage.widget.type=watchtower"
          "-l=homepage.widget.url=http://${vars.homelabStaticIp}:3003"
          "-l=homepage.widget.key={{HOMEPAGE_FILE_WATCHTOWER_KEY}}"
        ];
        volumes = [

          "${config.sops.secrets.watchtower-api-key.path}:/run/secrets/access_token"

          "/var/run/podman/podman.sock:/var/run/docker.sock:ro"
        ];
        ports = [ "3003:8080" ];
        environmentFiles = [ config.sops.secrets.watchtower-api-key.path ];
        environment = {
          TZ = vars.timeZone;
          WATCHTOWER_CLEANUP = "true";
          WATCHTOWER_HTTP_API_METRICS = "true";
          WATCHTOWER_SCHEDULE = "0 3 * * *"; # Every day at 3 AM
          WATCHTOWER_TRACE = "true";

          WATCHTOWER_HTTP_API_TOKEN = "/run/secrets/access_token";
        };
      };
    };
  };
}
