{ config, ... }: {
  virtualisation.oci-containers.containers = {
    changedetection = {
      image = "ghcr.io/dgtlmoon/changedetection.io:0.50.34";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Services"
        "-l=homepage.name=Changedetection"
        "-l=homepage.icon=changedetection.svg"
        "-l=homepage.href=http://${config.homelab.ip}:5000"
        "-l=homepage.description=Website change detection"

        "-l=homepage.widget.type=changedetectionio"
        "-l=homepage.widget.url=http://${config.homelab.ip}:5000"
        "-l=homepage.widget.key={{HOMEPAGE_FILE_CHANGEDETECTION_KEY}}"
      ];
      ports = [ "5000:5000" ];
      volumes = [ "changedetection-data:/datastore" ];
      # environment = { PLAYWRIGHT_DRIVER_URL = "ws://playwright-chrome:3000"; };
      # dependsOn = [ "playwright-chrome" ];
    };

    # playwright-chrome = {
    #   image = "dgtlmoon/sockpuppetbrowser:latest";
    #   autoStart = true;
    #   extraOptions = [ "--pull=newer" ];
    #   environment = {
    #     SCREEN_WIDTH = "1920";
    #     SCREEN_HEIGHT = "1024";
    #     SCREEN_DEPTH = "16";
    #     MAX_CONCURRENT_CHROME_PROCESSES = "10";
    #     ENABLE_DEBUGGER = "false";
    #     PREBOOT_CHROME = "true";
    #     CONNECTION_TIMEOUT = "300000";
    #     MAX_CONCURRENT_SESSIONS = "10";
    #     CHROME_REFRESH_TIME = "600000";
    #     DEFAULT_BLOCK_ADS = "true";
    #     DEFAULT_STEALTH = "true";
    #     DEFAULT_IGNORE_HTTPS_ERRORS = "true";
    #   };
    # };
  };
}
