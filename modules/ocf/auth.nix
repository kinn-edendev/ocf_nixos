{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.ocf.auth;
in
{
  options.ocf.auth = {
    enable = mkEnableOption "Enable OCF authentication";
  };

  config = mkIf (cfg.enable) {
    users.ldap = {
      enable = true;
      server = "ldaps://ldap.ocf.berkeley.edu";
      base = "dc=OCF,dc=Berkeley,dc=EDU";
      daemon.enable = true;
      extraConfig = ''
        tls_reqcert hard
        tls_cacert /etc/ssl/certs/ca-certificates.crt

        base dc=ocf,dc=berkeley,dc=edu
        nss_base_passwd ou=people,dc=ocf,dc=berkeley,dc=edu
        nss_base_group  ou=group,dc=ocf,dc=berkeley,dc=edu
      '';
    };

    security.krb5 = {
      enable = true;
      package = pkgs.heimdal;

      settings = {
        realms = {
          "OCF.BERKELEY.EDU" = {
            admin_server = "kerberos.ocf.berkeley.edu";
            kdc = [ "kerberos.ocf.berkeley.edu" ];
          };
        };
        domain_realm = {
          "ocf.berkeley.edu" = "OCF.BERKELEY.EDU";
          ".ocf.berkeley.edu" = "OCF.BERKELEY.EDU";
        };
        libdefaults = {
          default_realm = "OCF.BERKELEY.EDU";
        };
      };
    };
  };
}

