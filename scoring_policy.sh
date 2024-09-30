# special case for ssh only. we could expand this later.
check_fw_rules () {
#omg this is dumb holy crap
  val=$(ufw status numbered | sed 's/\ \ \ */:/g' | cut -f2 -d] | sed 's/^[[:blank:]]*//g' | grep -E -o "22/tcp:ALLOW IN:Anywhere")
  ret=$?
  debug "${FUNCNAME} ret = ###$ret###"
  [[ $ret != 0 ]] && record "Firewall rule to allow sshd is not active" -25
}

#### policy
#
#
check_ufw_enabled () {
  declare -n struct=policy
  add_possible_points ${struct[points]}
  val=$(ufw status | grep -E -o "Status: active")
  [[ $val == "Status: active" ]] && record "${struct[fwactive]}" ${struct[points]}
}

check_updates () {
  declare -n struct=policy
  add_possible_points ${struct[points]}
  upgrades=$(apt list --upgradable 2>/dev/null | wc -l)
  [[ ${upgrades} -le 1 ]] && record "${struct[updates]}" ${struct[points]}
}

# these are all greps into system files to ensure proper configuration
check_pwage () {
  declare -n struct=policy
  add_possible_points ${struct[points]}
  file="/etc/login.defs"
  age=$(grep ^PASS_MAX_DAYS $file |  cut -f2)
  [[ $age =~ [[:digit:]] && $age -le 90 ]] && record "${struct[pwage]}" ${struct[points]}
}

check_pwminlen () {
  declare -n struct=policy
  add_possible_points ${struct[points]}
  file="/etc/pam.d/common-password"
  val=$(grep -E -o minlen=[0-9]+ $file | cut -f2 -d=)
  [[ $val -ge 8 ]] && record "${struct[pwminlen]}" ${struct[points]}
}

check_pwhistory () {
  declare -n struct=policy
  add_possible_points ${struct[points]}
  file="/etc/pam.d/common-password"
  val=$(grep -E -o remember=[0-9]+ $file | cut -f2 -d=)
  [[ $val -ge 5 ]] && record "${struct[pwhistory]}" ${struct[points]}
}

check_pwnullok () {
  declare -n struct=policy
  add_possible_points ${struct[points]}
  file="/etc/pam.d/common-auth"
  val=$(grep -E -o nullok $file)
  ret=$?
  [[ $ret -eq 1 ]] && record "${struct[pwnullok]}" ${struct[points]}
}

check_pwquality () {
  declare -n struct=policy
  file="/etc/pam.d/common-password"
  entries=("ucredit" "lcredit" "dcredit" "ocredit")
  for entry in "${entries[@]}"; do
    add_possible_points ${struct[points]}
    ret=$(grep -E -o ${entry}=[0-9-]+ $file | cut -f2 -d=)
    [[ $ret -ne 0 ]] || return 1
  done
  record "${struct[pwquality]}" ${struct[points]}
}

check_ssh_root_login () {
  declare -n struct=policy
  add_possible_points ${struct[points]}
  file="/etc/ssh/sshd_config"
  entry="PermitRootLogin"
#  ret=$(grep -E -o ${entry}=[a-zA-Z]+ $file | cut -f2)
  ret=$(grep ^${entry} $file 2> /dev/null)
  [[ $? != 0 ]] && return 1
  val=$(echo "$ret" | tr -s " " | cut -f2 -d" ")
  [[ $val != "no" ]] && return 1
  record "${struct[permitroot]}" ${struct[points]}
}

