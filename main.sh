#!/usr/bin/env bash

uid=`id -g`
if [ "$uid" != "0" ]; then
  echo "run script with sudo"
  echo "sudo ${0}"
  exit
fi

# globals
declare -a results
total_points=0
possible_points=0
debug=0

source ./scoring.sh
source ./scoring_policy.sh
source ./scoring_stig.sh
source ./config.sh
source ./config_policy.sh
source ./config_stig.sh
source ./helpers.sh

record () {
  txt=$1
  points=$2
  if [[ $points -lt 0 ]]; then
    style='style="color:darkred"'
  else
    style='style="color:black"'
  fi
  results+=("<span ${style}>${txt} -- ${points} points</span><br />")
  ((total_points += $points))
}

declare -a modules_main
if [[ ${modules[negative]} -eq 0 ]]; then
# negative points | run these first so they appear at the top
  modules_main+=(
    "check_auth_users"
    "check_auth_admins"
    "check_apps_critical"
    "check_fw_rules" # did you add sshd rule?
  )
fi

# default modules
modules_main+=(
  "check_forensics"
  "check_updates"
  "check_apps_upgrade"
  "check_apps_install"
  "check_apps_unauth"
)

if [[ ${modules[users]} -eq 0 ]]; then
# user and group membership points
  modules_main+=(
    "check_unauth_users"
    "check_unauth_admins"
    "check_group_add"
    "check_user_in_group"
    "check_passwd_changed"   # tktk make sure designated users aren't \! in shadow
  )
fi

if [[ ${modules[policy]} -eq 0 ]]; then
  modules_main+=(
    "check_contraband"       # music/video files in /home/
    "check_root_passwd"      # tktk make sure root is usermod \! and passwd -l
    "check_ufw_enabled"
    "check_pwage"
    "check_pwminlen"
    "check_pwhistory"
    "check_pwquality"
    "check_pwnullok"
    "check_ssh_root_login"   # sshd_config PermitRoot...
  )
fi

if [[ ${modules[stig]} -eq 0 ]]; then
  : # tktk
fi

main () {
  for module in "${modules_main[@]}"; do
    $module
  done
  write_html "${results[@]}"
  debug "total points: ${total_points}"
}

main
