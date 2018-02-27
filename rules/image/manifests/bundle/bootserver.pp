class image::bundle::bootserver {
  include ::bootserver_autopoweron
  # include ::bootserver_backup                 # XXX needs work
  # include ::bootserver_cron                   # XXX needs work
  # include ::bootserver_cups                   # XXX needs work
  # include ::bootserver_ddns                   # XXX needs work
  # include ::bootserver_dummywlan              # XXX needs work
  # include ::bootserver_fluentd                # XXX needs work
  # include ::bootserver_helpers                # XXX needs work
  # include ::bootserver_hostname               # XXX needs work
  # include ::bootserver_inetd                  # XXX needs work
  # include ::bootserver_krb5kdc                # XXX needs work
  # include ::bootserver_kvm_ltspserver         # XXX needs work
  # include ::bootserver_ldap                   # XXX needs work
  # include ::bootserver_ltspimages             # XXX needs work
  # include ::bootserver_munin                  # XXX needs work
  # include ::bootserver_nagios                 # XXX needs work
  # include ::bootserver_nbd_server             # XXX needs work
  # include ::bootserver_network_interfaces     # XXX needs work
  # include ::bootserver_nfs                    # XXX needs work
  # include ::bootserver_nginx                  # XXX needs work
  # include ::bootserver_nss                    # XXX needs work
  # include ::bootserver_ntp                    # XXX needs work
  # include ::bootserver_pam                    # XXX needs work
  # include ::bootserver_pxe                    # XXX needs work
  # include ::bootserver_qemu                   # XXX needs work
  # include ::bootserver_samba                  # XXX needs work
  # include ::bootserver_slapd                  # XXX needs work
  # include ::bootserver_ssh_server             # XXX needs work
  # include ::bootserver_sudoers                # XXX needs work
  # include ::bootserver_syslog                 # XXX needs work
  # include ::bootserver_utmp                   # XXX needs work
  # include ::bootserver_vpn                    # XXX needs work
  # include ::bootserver_webdisk                # XXX needs work
  # include ::bootserver_wlan                   # XXX needs work
  include ::packages

  Package <| tag == tag_puavo_bootserver |>
}