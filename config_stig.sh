
declare -a stig_svcs_disabled=(
  "apache2" "autofs" "avahi-daemon" "bind9" "bluez" "cups" "dnsmasq"
  "dovecot-imapd" "ftp" "isc-dhcp-server" "ldap-utils"
  "nginx" "nfs-kernel-server" "nis" "rpcbind" "rsh-client" "rsync"
  "samba" "slapd" "snmpd" "squid" "talk" "telnet" "tftpd-hpa"
  "vsftpd" "xinetd" "xserver-common" "ypserv"
)

declare -a stig_sysctl_config=(
# configure ICMP
  "net.ipv4.icmp_echo_ignore_all=1"
  "net.ipv4.icmp_echo_ignore_broadcasts=1"
  "net.ipv4.icmp_ignore_bogus_error_messages=1"
# use ExecShield
  "kernel.exec-shield=1"
# use ASLR
  "kernel.randomize_va_space=2"
# disable ICMP redirects
"net.ipv4.conf.all.accept_redirects=0"
# disable IP redirects
  "net.ipv4.ip_forward=0"
  "net.ipv4.conf.all.send_redirects=0"
  "net.ipv4.conf.default.send_redirects=0"
# disable spoofing
  "net.ipv4.conf.all.rp_filter=1"
  "net.ipv4.conf.all.log_martians=1"
# disable source routing
  "net.ipv4.conf.all.accept_source_route=0"
# enable SYN flood protection
  "net.ipv4.tcp_max_syn_backlog=2048"
  "net.ipv4.tcp_synack_retries=2"
  "net.ipv4.tcp_syn_retries=5"
# syncookies are no longer a real thing
  "net.ipv4.tcp_syncookies=1"
# disable ipv6 (optional. this reduces attack surface)
  "net.ipv6.conf.all.disable_ipv6=1"
  "net.ipv6.conf.default.disable_ipv6=1"
  "net.ipv6.conf.lo.disable_ipv6=1"
)
