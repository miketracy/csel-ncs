
#### policy
#

# check mint updates
check_mint_updates () {
  points=3
  add_possible_points $points
  val=$(sudo -iu campy dbus-launch gsettings get com.linuxmint.updates refresh-schedule-enabled)
#  val=$(su campy -c "gsettings get com.linuxmint.updates refresh-schedule-enabled 2> /dev/null")
  debug $val
  if [[ "$val" == "true" ]]; then
    record "mint updates refresh schedule enabled" $points
  else
    record "MISS update configuration" 0
  fi
  add_possible_points $points
  val=$(service_active mintupdate-automation-upgrade.timer)
  if [[ $val -eq 0 ]]; then
    record "mint automatic update service running" $points
  else
    record "MISS update configuration" 0
  fi
}

# check that root console login has been disabled
# ensure root is usermod -p "!"
check_root_login () {
  points=2
  add_possible_points $points
  getent shadow root | cut -f2 -d: | grep -o ^\!
  [[ $? -eq 0 ]] && record "Interactive login for root disabled" $points
}

# special case
check_shadow_only () {
  local lpoints=6
  add_possible_points $lpoints
  ret=$(\
    diff \
    <(cat /etc/passwd | cut -f1 -d: | sort) \
    <(cat /etc/shadow | cut -f1 -d: | sort) \
  )
  ret=$?
  if [[ $ret == 0 ]]; then
    record "All users in /etc/shadow appear in /etc/passwd" $lpoints
  fi
}

# special case for ssh only. we could expand this later.
check_fw_rules () {
#omg this is dumb holy crap
  local lpoints=9
  add_possible_points $lpoints
  ret=$(ufw_rule_exists '22/tcp|ALLOW IN|Anywhere')
  if [[ $ret != 0 ]]; then
    record "MISS required firewall rule" 0
  else
    record "Firewall rule to allow sshd (tcp/22) is active" $lpoints
  fi
}

check_ufw_enabled () {
  declare -n hash=policy
  add_possible_points ${hash[points]}
  ter=$(which ufw)
  [[ $? -ne 0 ]] && return 127
  val=$(ufw status | grep -E -o "Status: active")
  [[ $val == "Status: active" ]] && record "${hash[fwactive]}" ${hash[points]}
}

check_updates () {
  declare -n hash=policy
  add_possible_points ${hash[points]}
  updates=$(apt list --upgradable 2>/dev/null | wc -l)
  [[ ${updates} -le 1 ]] && record "${hash[updates]}" ${hash[points]}
}

# these are all greps into system files to ensure proper configuration
check_pwage () {
  declare -n hash=policy
  add_possible_points ${hash[points]}
  file="/etc/login.defs"
  val=$(has_value $file "^PASS_MAX_DAYS" le 90)
  ret=$?
  debug "ret=$ret"
  [[ "$ret" -eq 0 ]] && record "${hash[pwage]}" ${hash[points]}
}

check_pwminlen () {
  declare -n hash=policy
  add_possible_points ${hash[points]}
  file="/etc/pam.d/common-password"
  ret=$(has_value $file "minlen" ge 8)
  ret=$?
  debug "ret=$ret"
  [[ $ret -eq 0 ]] && record "${hash[pwminlen]}" ${hash[points]}
}

check_pwhistory () {
  declare -n hash=policy
  add_possible_points ${hash[points]}
  file="/etc/pam.d/common-password"
  val=$(grep -E -o remember=[0-9]+ $file | cut -f2 -d=)
  [[ $val -ge 5 ]] && record "${hash[pwhistory]}" ${hash[points]}
}

check_pwnullok () {
  declare -n hash=policy
  add_possible_points ${hash[points]}
  file="/etc/pam.d/common-auth"
  val=$(grep -E -o nullok $file)
  ret=$?
  [[ $ret -eq 1 ]] && record "${hash[pwnullok]}" ${hash[points]}
}

check_pwquality () {
  declare -n hash=policy
  file="/etc/pam.d/common-password"
  entries=("ucredit" "lcredit" "dcredit" "ocredit")
  add_possible_points ${hash[points]}
  for entry in "${entries[@]}"; do
    ret=$(grep -E -o ${entry}=[0-9-]+ $file | cut -f2 -d=)
    [[ $? -ne 0 ]] && return 1
    [[ $ret -ne 0 ]] || return 1
  done
  record "${hash[pwquality]}" ${hash[points]}
}

check_ssh_root_login () {
  declare -n hash=policy
  add_possible_points ${hash[points]}
  file="/etc/ssh/sshd_config"
  entry="PermitRootLogin"
#  ret=$(grep -E -o ${entry}=[a-zA-Z]+ $file | cut -f2)
  ret=$(grep ^${entry} $file 2> /dev/null)
  [[ $? != 0 ]] && return 1
  val=$(echo "$ret" | tr -s " " | cut -f2 -d" ")
  [[ $val != "no" ]] && return 1
  record "${hash[permitroot]}" ${hash[points]}
}

check_auditd_running () {
  return 127
  declare -n hash=policy
  add_possible_points ${hash[points]}
  ret=$(package_installed auditd)
  [[ $? -ne 0 ]] && return 127
  ret=$(service_running auditd)
  [[ $? -ne 0 ]] && return 127
  record "${hash[auditd]}" ${hash[points]}
}
