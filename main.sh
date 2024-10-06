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
source ./tests.sh

record () {
  txt=$1
  points=$2
  debug "$1 -- $2"
  if [[ $points -lt 0 ]]; then
    style='style="color:darkred"'
  else
    style='style="color:black"'
  fi
  results+=("<span ${style}>[${FUNCNAME[1]}] ${txt} -- ${points} points</span><br />")
  ((total_points += $points))
}

declare -a modules_main
if [[ ${modules[negative]} -eq 0 ]]; then
# negative points | run these first so they appear at the top
  modules_main+=(
    "check_services_critical"
    "check_packages_critical"
    "check_users_auth"
    "check_admins_auth"
    "check_fw_rules" # did you add sshd rule?
  )
fi

# default modules
modules_main+=(
  "check_forensics"
  "check_updates"
  "check_services_unauth"
  "check_services_installed"
  "check_packages_upgrade"
  "check_packages_installed"
  "check_packages_unauth"
)

if [[ ${modules[users]} -eq 0 ]]; then
# user and group membership points
  modules_main+=(
    "check_users_unauth"
    "check_admins_unauth"
    "check_group_add"
    "check_user_in_group"
    "check_password_change"        # check designated users have changed their password
  )
fi

if [[ ${modules[policy]} -eq 0 ]]; then
  modules_main+=(
    "check_shadow_only"            # check users in /etc/shadow not in /etc/passwd
    "check_contraband"             # music/video files in /home/
    "check_ufw_enabled"
    "check_pwage"
    "check_pwminlen"
    "check_pwhistory"
    "check_pwquality"
    "check_pwnullok"
    "check_ssh_root_login"         # sshd_config PermitRoot...
    "check_insecure_passwd_algos"  # tktk algos in /etc/shadow are all $y$ or chage -d 0
    "check_root_login"             # tktk make sure root is usermod \! and passwd -l
    "check_home_perms"             # tktk check secure permissions in /home/
  )
fi

if [[ ${modules[stig]} -eq 0 ]]; then
  : # tktk
fi

check_modules () {
  scores=$(cat scoring*.sh | grep ^check | cut -f1 -d" " | sort)
  printf -v mains "%s\n" "${modules_main[@]}"
  mains=${mains%?}
  ret=$(diff <(echo "$mains" | sort) <(echo "$scores" | sort))
  [[ "$?" -ne 0 ]] &&  fatal "functions do not match [$ret]"
}

main () {
  for module in "${modules_main[@]}"; do
    echo "$module"
    debug "RUNNING $module"
    $module
  done
  write_html "${results[@]}"
  debug "total points: ${total_points}"
}

if [[ "$SUDO_USER" != "" ]]; then
  debug "checking modules"
  check_modules
else
  debug "not checking modules"
fi

main
