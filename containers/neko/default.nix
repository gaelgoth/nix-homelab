{
  virtualisation.oci-containers.containers = {
    neko = {
      image = "m1k1o/neko:firefox";
      autoStart = true;
      extraOptions = [
        "--pull=newer"
        "-l=homepage.group=Services"
        "-l=homepage.name=Neko"
        "-l=homepage.icon=neko.svg"
        "-l=homepage.href=http://192.168.1.5:3023/"
        "-l=homepage.description=Remote browser service with Firefox"
      ];
      ports = [ "3023:8080" "52000-52100:52000-52100/udp" ];
      environment = {
        NEKO_SCREEN = "1024x576@30";
        NEKO_PASSWORD = "neko";
        NEKO_PASSWORD_ADMIN = "admin";
        NEKO_EPR = "52000-52100";
        NEKO_ICELITE = "0";
        NEKO_NAT1TO1 = "192.168.1.5";
      };
    };
  };
}
