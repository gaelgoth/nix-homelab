{ config, pkgs, ... }:
{

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "server";

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.allowedUDPPorts = [ config.services.tailscale.port ];
  networking.firewall.allowedTCPPorts = [ config.services.tailscale.port ];

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    # make sure tailscale is running before trying to connect to tailscale
    after = [
      "network-pre.target"
      "tailscale.service"
    ];
    wants = [
      "network-pre.target"
      "tailscale.service"
    ];
    wantedBy = [ "multi-user.target" ];

    # set this service as a oneshot job
    serviceConfig.Type = "oneshot";

    # have the job run this shell script
    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if tailscale is connected and already advertising desired routes
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      configured="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r '((.Self.AdvertisedRoutes // []) | index("192.168.1.0/24") != null) and ((.Self.AdvertisedRoutes // []) | index("0.0.0.0/0") != null) and ((.Self.AdvertisedRoutes // []) | index("::/0") != null)')"

      if [[ "$status" = "Running" ]] && [[ "$configured" = "true" ]]; then
        exit 0
      fi

      # otherwise ensure subnet-router and exit-node advertisement are enabled
      ${tailscale}/bin/tailscale up --advertise-routes=192.168.1.0/24 --advertise-exit-node
    '';
  };

}
