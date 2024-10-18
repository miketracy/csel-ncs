# check for STIG sshd_config
check_stig_sshd_config () {
  local lpoints=5
  add_possible_points $lpoints
  file="/etc/ssh/sshd_config"
  local -n hash=stig_sshd_config_hash
  sret=0
  for key in "${!hash[@]}"; do
    ret=$(has_value $file "^$key" "==" "${hash[$key]}")
    if [[ "$?" -ne 0 ]]; then
      sret=1
    fi
  done
  if [[ $sret -eq 0 ]]; then
    record "sshd_config configured to STIG" $lpoints
  else
    record "MISS sshd_config STIG config" 0
  fi
  return $sret
}

# check for STIG sysctl config
check_stig_sysctl_config () {
  local lpoints=5
  add_possible_points $lpoints
  file="/etc/sysctl.conf"
  local -n hash=stig_sysctl_config_hash
  sret=0
  for key in "${!hash[@]}"; do
    ret=$(has_value $file "^$key" "==" "${hash[$key]}")
    if [[ "$?" -ne 0 ]]; then
      sret=1
    fi
  done
  if [[ $sret -eq 0 ]]; then
    record "sysctl configured to STIG" $lpoints
  else
    record "MISS sysctl STIG config" 0
  fi
  return $sret
}

# check for STIG lightdm config
check_stig_lightdm_config () {
  local lpoints=5
  add_possible_points $lpoints
  local file="/etc/lightdm/lightdm.conf"
  if [[ ! -f "$file" ]]; then
    record "MISS lightdm STIG config" 0
    return 127
  fi
  local -n hash=stig_lightdm_config_hash
  for key in "${!hash[@]}"; do
    ret=$(has_value $file "^$key" "==" "${hash[$key]}")
    if [[ "$?" -ne 0 ]]; then
      record "MISS lightdm STIG config" 0
      return 127
    fi
  done
  record "lightdm configured to STIG" $lpoints
}

# check that inetd is removed or masked
check_stig_inetd_masked () {
  local lpoints=5
  add_possible_points $lpoints
  pret=$(package_installed "openbsd-inetd")
  debug $pret
  if [[ $pret -eq 0 ]]; then
    mret=$(systemctl is-enabled inetd)
#    if [[ $mret != "masked" && $mret != "disabled" ]]; then
    if [[ $mret != "masked" ]]; then
      debug $mret
      return 127
    fi
  fi
  record "inetd removed or masked" $lpoints
}

debug_check_stig () {
  [[ $debug -lt 2 ]] && return 1
  declare -n struct=stig_checks
  for key in ${!struct[@]}; do
    if [[ "$key" != "points" ]]; then
      declare -n list="${struct[$key]}"
      debug "testing: $key"
      for val in "${list[@]}"; do
        debug "${key} has ${val}"
      done
    fi
  done
}
