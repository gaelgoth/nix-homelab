{ config, vars, ... }: {

  sops.secrets."cloudflared-creds" = { };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "nix-homelab" = {
        credentialsFile = "${config.sops.secrets.cloudflared-creds.path}";
        ingress = { "glance.gothuey-public.app" = "http://192.168.1.5:3027"; };
        default = "http_status:404";
      };
    };
  };
}
