
#### policy
#
# special case for ssh only. we could expand this later.
check_fw_rules () {
#omg this is dumb holy crap
  add_possible_points 25
  val=$(ufw status numbered | sed 's/\ \ \ */:/g' | cut -f2 -d] | sed 's/^[[:blank:]]*//g' | grep -E -o "22/tcp:ALLOW IN:Anywhere")
  ret=$?
  if [[ $ret != 0 ]]; then
    record "Firewall rule to allow sshd (tcp/22) is not active" -25
  else
    record "Firewall rule to allow sshd (tcp/22) is active" 25
  fi
}

check_ufw_enabled () {
  declare -n hash=policy
  add_possible_points ${hash[points]}
  val=$(ufw status | grep -E -o "Status: active")
  [[ $val == "Status: active" ]] && record "${hash[fwactive]}" ${hash[points]}
}

check_updates () {
  declare -n hash=policy
  add_possible_points ${hash[points]}
  upgrades=$(apt list --upgradable 2>/dev/null | wc -l)
  [[ ${upgrades} -le 1 ]] && record "${hash[updates]}" ${hash[points]}
}

# these are all greps into system files to ensure proper configuration
check_pwage () {
  declare -n hash=policy
  add_possible_points ${hash[points]}
  file="/etc/login.defs"
  age=$(grep ^PASS_MAX_DAYS $file |  cut -f2)
  [[ $age =~ [[:digit:]] && $age -le 90 ]] && record "${hash[pwage]}" ${hash[points]}
}

check_pwminlen () {
  declare -n hash=policy
  add_possible_points ${hash[points]}
  file="/etc/pam.d/common-password"
  val=$(grep -E -o minlen=[0-9]+ $file | cut -f2 -d=)
  [[ $val -ge 8 ]] && record "${hash[pwminlen]}" ${hash[points]}
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

