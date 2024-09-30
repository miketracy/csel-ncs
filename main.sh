#!/usr/bin/env bash

uid=`id -g`
if [ "$uid" != "0" ]; then
  echo "run script with sudo"
  echo "sudo ${0}"
  exit
fi

# globals
#declare -a __list # global variable hack for csv2arr
#declare -a results
#total_points=0


source ./scoring.sh
source ./config.sh
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

declare -a modules=(
# minus points
  "check_auth_users"
  "check_auth_admins"
  "check_critical_apps"
# plus points
  "check_forensics"
  "check_updates"
  "check_apps_upgrade"
  "check_apps_install"
  "checkapps_unauth"
  "check_contraband" # music/video files in /home/
  "check_unauth_users"
  "check_unauth_admins"
  "check_group_add"
  "check_user_in_group"
  "check_passwd_changed" # tktk make sure designated users aren't "!" in shadow
  "check_root_passwd" # tktk make sure root is usermod "!" and passwd -l
  "check_ufw_enabled"
  "check_fw_rules" # did you add sshd rule?
  "check_pwage"
  "check_pwminlen"
  "check_pwhistory"
  "check_pwquality"
  "check_pwnullok"
  "check_ssh_root_login"
)

main () {
  for module in "${modules[@]}"; do
    $module
  done
  write_html "${results[@]}"
  debug "total points: ${total_points}"
}

main
