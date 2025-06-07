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

  services.loki = {
    enable = true;
    configuration = {
      server.http_listen_port = 3030;
      auth_enabled = false;

      ingester = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore = { store = "inmemory"; };
            replication_factor = 1;
          };
        };
        chunk_idle_period = "1h";
        max_chunk_age = "1h";
        chunk_target_size = 999999;
        chunk_retain_period = "30s";
      };

      schema_config = {
        configs = [{
          from = "2022-06-06";
          store = "boltdb-shipper";
          object_store = "filesystem";
          schema = "v11";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }];
      };

      storage_config = {
        boltdb_shipper = {
          active_index_directory = "/var/lib/loki/boltdb-shipper-active";
          cache_location = "/var/lib/loki/boltdb-shipper-cache";
          cache_ttl = "24h";
        };

        filesystem = { directory = "/var/lib/loki/chunks"; };
      };

      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
        allow_structured_metadata = false; # Disable structured metadata
      };

      table_manager = {
        retention_deletes_enabled = false;
        retention_period = "0s";
      };

      compactor = {
        working_directory = "/var/lib/loki";
        compactor_ring = { kvstore = { store = "inmemory"; }; };
      };
    };
  };

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 3031;
        grpc_listen_port = 0;
      };
      positions = { filename = "/tmp/positions.yaml"; };
      clients = [{
        url = "http://127.0.0.1:${
            toString config.services.loki.configuration.server.http_listen_port
          }/loki/api/v1/push";
      }];
      scrape_configs = [{
        job_name = "journal";
        journal = {
          max_age = "12h";
          labels = {
            job = "systemd-journal";
            host = "nixos-homelab-vm";
            env = "homelab";
            instance = "homelab.local";
          };
        };
        relabel_configs = [{
          source_labels = [ "__journal__systemd_unit" ];
          target_label = "unit";
        }];
      }];
    };
    # extraFlags
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
        static_configs = [{ targets = [ "127.0.0.1:9618" ]; }];
      }
      {
        job_name = "cloudflared";
        scrape_interval = "15s";
        static_configs = [{ targets = [ "127.0.0.1:20241" ]; }];
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
