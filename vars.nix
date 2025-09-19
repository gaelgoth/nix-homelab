{
  homelabStaticIp = "192.168.1.5";
  nasStaticIp = "192.168.1.2";
  defaultDomain = "homelab.gothuey.dev";

  timeZone = "Europe/Zurich";
  mediaPath = "/mnt/media";
  # Toggle to enable routing supported containers (e.g. qBittorrent) through the Gluetun
  # VPN container. When false, those containers expose their own ports directly and
  # the Gluetun container (and related secrets) are not instantiated.
  enableGluetun = false;
}
