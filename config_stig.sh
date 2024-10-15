
declare -a stig_services_disable_list=(
  "apache2" "autofs" "avahi-daemon" "bind9" "bluetooth" "bluez" "cups"
  "dnsmasq" "dovecot-imapd" "ftp" "isc-dhcp-server" "ldap-utils"
  "nginx" "nfs-kernel-server" "nis" "rpcbind" "rsh-client" "rsync"
  "samba" "slapd" "snmpd" "squid" "talk" "telnet" "tftpd-hpa"
  "vsftpd" "xinetd" "xserver-common" "ypserv"
)

declare -A stig_sysctl_config_list=(
# configure ICMP
  [net.ipv4.icmp_echo_ignore_all]="1"
  [net.ipv4.icmp_echo_ignore_broadcasts]="1"
  [net.ipv4.icmp_ignore_bogus_error_messages]="1"
# use ExecShield
  [kernel.exec-shield]="1"
# use ASLR
  [kernel.randomize_va_space]="2"
# disable ICMP redirects
  [net.ipv4.conf.all.accept_redirects]="0"
# disable IP redirects
  [net.ipv4.ip_forward]="0"
  [net.ipv4.conf.all.send_redirects]="0"
  [net.ipv4.conf.default.send_redirects]="0"
# disable spoofing
  [net.ipv4.conf.all.rp_filter]="1"
  [net.ipv4.conf.all.log_martians]="1"
# disable source routing
  [net.ipv4.conf.all.accept_source_route]="0"
# enable SYN flood protection
  [net.ipv4.tcp_max_syn_backlog]="2048"
  [net.ipv4.tcp_synack_retries]="2"
  [net.ipv4.tcp_syn_retries]="5"
# syncookies are no longer a real thing
  [net.ipv4.tcp_syncookies]="1"
# disable ipv6 (optional. this reduces attack surface)
  [net.ipv6.conf.all.disable_ipv6]="1"
  [net.ipv6.conf.default.disable_ipv6]="1"
  [net.ipv6.conf.lo.disable_ipv6]="1"
)

declare -A stig_sshd_config_list=(
  [PermitRootLogin]="no"
  [Protocol]="2"
  [DisableForwarding]="yes"
  [GSSAPIAuthentication]="no"
  [HostbasedAuthentication]="no"
  [IgnoreRhosts]="yes"
  [PermitEmptyPasswords]="no"
  [PermitUserEnvironment]="no"
  [UsePAM]="yes"
)

declare -A stig_lightdm_config_list=(
  [allow-guest]="false"
  [autologin-guest]="false"
  [greeter-hide-users]="true"
  [greeter-show-manual-login]="true"
  [greeter-allow-guest]="false"
  [autologin-user]="none"
)

declare -a stig_gdm3_config_list=(
  "tktk not implemented"
)

declare -A stig_services_disable=(
  [points]=10
  [text]="Services are securely configured"
  [type]=service_active_not
  [list]=stig_services_disable_list
)

declare -A stig_sysctl_config=(
  [points]=10
  [type]=has_line
  [text]="systcl is securely configured"
  [file]="/etc/sysctl.conf"
  [list]=stig_sysctl_config_list
)

declare -A stig_sshd_config=(
  [points]=10
  [text]="sshd_config is securely configured"
  [type]=has_line
  [file]="/etc/ssh/sshd_config"
  [list]=stig_sysctl_config_list
)

declare -A stig_lightdm_config=(
  [points]=10
  [text]="lightdm is securely configured"
  [type]=has_line
  [file]="tktk not implemented"
  [list]=stig_lightdm_config_list
)

declare -A stig_gdm3_config=(
  [points]=10
  [text]="gdm3 is securely configured"
  [type]=has_line
  [file]="tktk not implemented"
  [list]=stig_gdm3_config_list
)

