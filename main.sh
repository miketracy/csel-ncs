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
source ./scoring_mean.sh
source ./scoring_stig.sh
source ./config.sh
source ./config_policy.sh
source ./config_mean.sh
source ./config_stig.sh
source ./helpers.sh
source ./tests.sh

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
if [[ ${modules[defaults]} -eq 0 ]]; then
  modules_main+=(
    "check_forensics"
    "check_updates"
    "check_services_unauth"
    "check_services_installed"
    "check_packages_upgrade"
    "check_packages_installed"
    "check_packages_unauth"
  )
fi

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
    "check_mint_updates"
    "check_auditd_running"
    "check_shadow_only"            # check users in /etc/shadow not in /etc/passwd
    "check_contraband"             # music/video files in /home/
    "check_ufw_enabled"
    "check_pwage"
    "check_pwminlen"
    "check_pwhistory"
    "check_pwquality"
    "check_pwnullok"
    "check_ssh_root_login"         # sshd_config PermitRoot...
    "check_root_login"             # make sure root is usermod \! and passwd -l
  )
fi

if [[ ${modules[mean]} -eq 0 ]]; then
  modules_main+=(
    "check_shadow_insecure_hash"
    "check_cron_allow"
    "check_home_perms"             # check secure permissions in /home/
    "check_world_writable"         # check world writable files set in setup.sh
    "check_reverse_shell"          # check crontab entry for reverse shell (u:harry)
    "check_suid_files"             # check for suid executables set in setup.sh
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
    debug "$module"
    debug "RUNNING $module"
    $module
  done
  write_html "${results[@]}"
  debug "total points: ${total_points}"
}

if [[ "$SUDO_USER" == "" ]]; then
  debug=1
else
  if [[ "$0" =~ simple_score ]]; then
    :
  else
    debug "checking modules"
    check_modules
  fi
fi

main
