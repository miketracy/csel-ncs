#!/usr/bin/env bash

uid=`id -g`
if [ "$uid" != "0" ]; then
  echo "run script with sudo"
  echo "sudo ${0}"
  exit
fi

source ./helpers.sh
source ./config.sh

# globals
declare -a __list # global variable hack for csv2arr
declare -a results
total_points=0

# hack to create a global variable with an array parsed from a csv list
# global: __list
# pass: csv string (no spaces between entries)
#csv2arr () {
#  line=$1
#  readarray -d ',' -t __list < <(printf $line) # use printf to prevent trailing \n
#}

record () {
  txt=$1
  points=$2
  if [[ $points -lt 0 ]]; then
    style='style="color:darkred"'
  else
    style='style="color:black"'
  fi
  results+=("<p ${style}>${txt} -- ${points} points</p>")
  ((total_points += $points))
}

check_updates () {
  upgrades=$(apt list --upgradable 2>/dev/null | wc -l)
  [[ ${upgrades} -le 1 ]] && record "${policy[updates]}" ${policy[points]}
}

check_group_add () {
  csv2arr "${groups_add[list]}"
  for group in "${__list[@]}"; do
    ret=$(exist_group $group)
    if [[ $ret -eq 0 ]]; then
      record "${groups_add[text]}: ${group}" ${groups_add[points]}
    fi
  done
}

# these are all greps into system files to ensure proper configuration
check_pwage () {
  file="/etc/login.defs"
  age=$(grep ^PASS_MAX_DAYS $file |  cut -f2)
  [[ $age =~ [[:digit:]] && $age -le 90 ]] && record "${policy[pwage]}" ${policy[points]}
}

check_pwminlen () {
  file="/etc/pam.d/common-password"
  val=$(grep -E -o minlen=[0-9]+ $file | cut -f2 -d=)
  [[ $val -ge 8 ]] && record "${policy[pwminlen]}" ${policy[points]}
}

check_pwhistory () {
  file="/etc/pam.d/common-password"
  val=$(grep -E -o remember=[0-9]+ $file | cut -f2 -d=)
  [[ $val -ge 5 ]] && record "${policy[pwhistory]}" ${policy[points]}
}

check_pwnullok () {
  file="/etc/pam.d/common-auth"
  val=$(grep -E -o nullok $file)
  ret=$?
  [[ $ret -eq 1 ]] && record "${policy[pwnullok]}" ${policy[points]}
}

check_pwquality () {
  file="/etc/pam.d/common-password"
  entries=("ucredit" "lcredit" "dcredit" "ocredit")
  for entry in "${entries[@]}"
  do
    ret=$(grep -E -o ${entry}=[0-9-]+ $file | cut -f2 -d=)
    [[ $ret -ne 0 ]] || return 1
  done
  record "${policy[pwquality]}" ${policy[points]}
}

check_ssh_root_login () {
  file="/etc/ssh/sshd_config"
  entry="PermitRootLogin"
#  ret=$(grep -E -o ${entry}=[a-zA-Z]+ $file | cut -f2)
  ret=$(grep ^${entry} $file 2> /dev/null)
  [[ $? != 0 ]] && return 1
  val=$(echo "$ret" | tr -s " " | cut -f2 -d" ")
  [[ $val != "no" ]] && return 1
  record "${policy[permitroot]}" ${policy[points]}
}

check_user_in_group () {
  csv2arr "${addtogroup[list]}"
  group="${addtogroup[name]}"
  for user in "${__list[@]}"; do
    ret=$(exist_user_in_group $group $user)
    if [[ $ret -eq 0 ]]; then
      record "User $user has been added to $group" ${policy[points]}
    fi
  done
}

check_auth_users () {
  csv2arr "${users_auth[list]}"
  for user in "${__list[@]}"; do
    ret=$(exist_user $user)
    if [[ $ret -ne 0 ]]; then
      record "${users_auth[text]}: $user" ${users_auth[points]}
    fi
  done
}

check_auth_admins () {
  csv2arr "${admins_auth[list]}"
  for user in "${__list[@]}"; do
    ret=$(exist_admin $user)
    if [[ $ret -ne 0 ]]; then
      record "${admins_auth[text]}: $user" ${admins_auth[points]}
    fi
  done
}

check_unauth_users () {
  csv2arr "${users_unauth[list]}"
  for user in "${__list[@]}"; do
    ret=$(exist_user $user)
    if [[ $ret -ne 0 ]]; then
      record "${users_unauth[text]}: $user" ${users_unauth[points]}
    fi
  done
}

check_unauth_admins () {
  csv2arr "${admins_unauth[list]}"
  for user in "${__list[@]}"; do
    ret=$(exist_admin $user)
    if [[ $ret -ne 0 ]]; then
      record "${admins_unauth[text]}: $user" ${admins_unauth[points]}
    fi
  done
}

check_critical_apps () {
  csv2arr "${apps_auth[list]}"
  for app in "${__list[@]}"; do
    ret=$(is_installed $app)
    insret=$?
    if [[ $insret -ne 0 ]]; then
      record "${apps_auth[text]}: $app" ${apps_auth[points]}
    fi
  done
}

check_apps_upgrade () {
  csv2arr "${apps_upgrade[list]}"
  for app in "${__list[@]}"; do
    ret=$(is_upgradable $app)
    upgret=$?
    if [[ $upgret == 1 ]]; then
      record "${apps_upgrade[text]}: $app" ${apps_upgrade[points]}
    fi
  done
}

check_contraband () {
  loc="${contraband_files[location]}"
  csv2arr "${contraband_files[files]}"
  for file in "${__list[@]}"; do
    if [[ ! -f ${loc}/${file} ]]; then
      record "${contraband_files[text]}: $file" ${contraband_files[points]}
    fi
  done
}

check_ufw_enabled () {
  val=$(ufw status 2&>1 | grep -E -o "Status: active")
  [[ $val == "Status: active" ]] && record "${policy[fwactive]}" ${policy[points]}
}

check_apps_install () {
  csv2arr "${apps_install[list]}"
  for app in "${__list[@]}"; do
    ret=$(is_installed $app)
    insret=$?
    if [[ $insret == 0 ]]; then
      record "${apps_install[text]}: $app" ${apps_install[points]}
    fi
  done
}

check_apps_unauth () {
  csv2arr "${apps_unauth[list]}"
  for app in "${__list[@]}"; do
    ret=$(is_installed $app)
    insret=$?
    if [[ $insret == 1 ]]; then
      record "${apps_unauth[text]}: $app" ${apps_unauth[points]}
    fi
  done
}

# special case for ssh only. we could expand this later
check_fw_rules () {
#omg this is dumb holy crap
  val=$(ufw status numbered 2&>1 | sed 's/\ \ \ */:/g' | cut -f2 -d] | sed 's/^[[:blank:]]*//g' | grep -E -o "22/tcp:ALLOW IN:Anywhere")
  ret=$?
  [[ $ret != 0 ]] && record "Firewall rule to allow sshd is not active" -25
}

check_forensics () {
  for file in "${!forensics_answers[@]}"; do
    if [[ -f "${location}/${file}" ]]; then
      ans=$(grep -E -o ANSWER.* ${location}/${file} | sed 's/ANSWER:\ //g')
      if [[ $ans == "${forensics_answers["$file"]}" ]]; then
        record "${forensics_answers[text]}: ${file}" ${forensics_answers[points]}
      fi
    fi
  done
}

# TODO
# x check for nullok in password policy
# x firewall running
# firewall rule for ssh
# x check installed x2goserver,ruby
# x check files in /home/garry/Music/
# x get original versions of all files we modify for setup
# x auth users?
# x auth admins?
# x check firewall rule for 22/tcp
# test all values against [:digit:]
# check for changed pasword
#   create user password and compare hash to known bad
#   getent shadow $user (sudo)
# x add forensics questions
# check for plaintext passwords in /etc/shadow
# check perms on /home/
# check for setuid files
# make sure all passwords are in /etc/shadow (pwent user:x:...)
# make sure all users in /etc/shadow are in /etc/password
# check config of /etc/sysctl.conf
#
# add lightdm configs
#
# minus points
check_auth_users
check_auth_admins
check_critical_apps
# plus points
check_forensics
check_updates
check_apps_upgrade
check_apps_install
check_apps_unauth
check_contraband # music/video files in /home/
check_unauth_users
check_unauth_admins
check_group_add
check_user_in_group
check_passwd_changed # tktk make sure designated users aren't "!" in shadow
check_root_passwd # tktk make sure root is usermod "!" and passwd -l
check_ufw_enabled
check_fw_rules # did you add sshd rule?
check_pwage
check_pwminlen
check_pwhistory
check_pwquality
check_pwnullok
check_ssh_root_login

write_html "${results[@]}"
#for line in "${results[@]}"; do
#  echo $line
#done
#echo ${results[@]}

echo "total points: ${total_points}"
