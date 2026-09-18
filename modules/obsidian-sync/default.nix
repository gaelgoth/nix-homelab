{ config, lib, pkgs, ... }:
let
  package = pkgs.obsidian-headless;
  stateDir = "/var/lib/obsidian-sync";
  vaultDir = "${stateDir}/vault";
  hermesOutputDir = "${vaultDir}/Hermes";
in {
  # Puts `ob` on PATH for manual `ob login` / `ob sync-setup` (the systemd
  # unit below calls it by absolute store path, so doesn't need this).
  environment.systemPackages = [ package ];

  users.groups.obsidian-vault = { };
  users.users = {
    obsidian-sync = {
      isSystemUser = true;
      group = "obsidian-vault";
      home = stateDir;
      createHome = true;
      homeMode = "0750";
      shell = pkgs.bashInteractive;
    };
    hermes.extraGroups = [ "obsidian-vault" ];
  };

  systemd.tmpfiles.rules = [
    "d ${stateDir} 0750 obsidian-sync obsidian-vault - -"
    "d ${vaultDir} 2750 obsidian-sync obsidian-vault - -"
    "d ${hermesOutputDir} 2770 hermes obsidian-vault - -"
  ];

  systemd.services = {
    obsidian-sync = {
      description = "Obsidian Headless continuous vault sync";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      environment = {
        HOME = stateDir;
        XDG_CONFIG_HOME = "${stateDir}/.config";
      };

      serviceConfig = {
        User = "obsidian-sync";
        Group = "obsidian-vault";
        WorkingDirectory = vaultDir;
        # Stays inactive (rather than crash-looping) until `ob login` +
        # `ob sync-setup` have been run interactively as obsidian-sync.
        ExecCondition = "${package}/bin/ob sync-status --path ${vaultDir}";
        # Make existing Hermes output notes group-writable on every service
        # start, so the hermes agent (a member of the obsidian-vault group) can
        # append to notes it didn't create (e.g. log to Hermes/01-fitness-goal.md).
        ExecStartPre = "${pkgs.coreutils}/bin/chmod -R g+w ${hermesOutputDir}";
        ExecStart = "${package}/bin/ob sync --continuous --path ${vaultDir}";
        Restart = "on-failure";
        RestartSec = 10;
        # 0007 (not 0027): notes pulled from Obsidian are born group-writable
        # (rw-rw----) for the obsidian-vault group, so the agent can write to
        # them even before the next service start would chmod them.
        UMask = "0007";

        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadWritePaths = [ stateDir ];
      };
    };

    hermes-agent.serviceConfig = {
      ReadOnlyPaths = [ vaultDir ];
      ReadWritePaths = [ hermesOutputDir ];
      SupplementaryGroups = [ "obsidian-vault" ];
    };
  };

  assertions = [{
    assertion = config.services.hermes-agent.enable;
    message =
      "The Obsidian Sync integration requires services.hermes-agent.enable.";
  }];
}
