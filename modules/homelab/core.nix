{ lib, config, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.homelab = {
    ip = mkOption {
      type = types.str;
      description = "Primary homelab host IP address";
      default = "192.168.1.5";
    };
    nasIp = mkOption {
      type = types.str;
      description = "NAS static IP address";
      default = "192.168.1.2";
    };
    domain = mkOption {
      type = types.str;
      description = "Base domain for homelab services";
      default = "homelab.gothuey.dev";
    };
    mediaPath = mkOption {
      type = types.path;
      description = "Root path where media is mounted";
      default = "/mnt/media";
    };
  };
}
