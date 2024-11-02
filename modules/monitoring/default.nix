{ config, ... }: {
  networking.firewall.allowedTCPPorts = [ 2342 ];

  services.grafana = {
    enable = true;
    domain = "localhost";
    port = 2342;
    addr =
      ""; # listen (bind) to all network interfaces (i.e. 127.0.0.1, and ipAddress)
  };

  services.prometheus = {
    scrapeConfigs = [{
      job_name = "node";
      static_configs = [{
        targets = [
          "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
        ];
      }];
    }];
    enable = true;
    port = 9001;
    exporters = {
      node = {
        enable = true;
        port = 9002;
      };
    };
  };
}
