{ config, ... }: {
  networking.firewall.allowedTCPPorts = [ 2342 ];

  services.grafana = {
    enable = true;
    settings.server = {
      domain = "localhost";
      http_port = 2342;
      http_addr =
        ""; # listen (bind) to all network interfaces (i.e. 127.0.0.1, and ipAddress)
    };
  };

  services.prometheus = {
    scrapeConfigs = [
      {
        job_name = "node";
        scrape_interval = "15s";
        static_configs = [{
          targets = [
            "127.0.0.1:${
              toString config.services.prometheus.exporters.node.port
            }"
          ];
        }];
      }
      {
        job_name = "snmp";
        scrape_interval = "30s";
        static_configs = [{ targets = [ "192.168.1.2" ]; }];
        metrics_path = "/snmp";
        params = {
          auth = [ "public_v3" ];
          module = [ "synology" ];
        };
        relabel_configs = [
          {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
          }
          {
            source_labels = [ "__param_target" ];
            target_label = "instance";
          }
          {
            target_label = "__address__";
            replacement =
              "192.168.1.2:9116"; # The SNMP exporter's real hostname:port
          }
        ];
      }
      {
        job_name = "adguard";
        scrape_interval = "15s";
        static_configs = [{
          targets = [
            "127.0.0.1:9618"
          ];
        }];
      }
    ];
    enable = true;
    port = 9001;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
    };
  };
}
