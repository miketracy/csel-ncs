# check set world-writable files
check_world_writable () {
  points=5
  local -a files=(
    "/etc/ssh/ssh_config"
    "/etc/ssh/sshd_config"
  )
  add_possible_points $points
  for file in "${files[@]}"; do
    txt=$(getfacl -p $file | grep other | cut -f3 -d: | grep -E -o .w.)
    ret=$?
    if [[ $ret -eq 0 ]]; then
      record "MISS suspect world writable files" 0
      return 127
    fi
  done
  record "suspect world writable files have been fixed" $points
}

# facile check for presence of harry reverse shell crontab
check_reverse_shell () {
  points=11
  add_possible_points $points
  txt=$(crontab -l -u harry)
  ret=$?
  if [[ $ret -eq 1 ]]; then
    record "reverse shell removed from crontab" $points
  else
    record "MISS persistence mechanism" 0
  fi
}

# facile check for suid file from setup
check_suid_files () {
  points=5
  add_possible_points $points
  [[ ! -f /var/log/.harmless ]] && record "setuid executable removed" $points
}

# check for secure permissions in /home/
check_home_perms () {
  points=2
  add_possible_points $points
  ret=$(ls -l /home/ | grep -e total -e ^drwxr-x--- -v | wc -l)
  if [[ "$ret" -eq 0 ]]; then
    record "Permissions in /home/ are secure" $points
  else
    record "MISS secure file permissions" 0
  fi
}

# special case
# check for any non $y$ algos in /etc/shadow
# make sure users are all chage -d 0
check_insecure_passwd_algos () {
  debug "NOT IMPLEMENTED"
  return 127
  points=2
  add_possible_points $points
  ret=$(cat /etc/shadow | cut -f2 -d: | grep -e '\!$' -e '*$' -e '^\$y\$' -v | w
c -l)
  [[ "$ret" -eq 0 ]] && record "Permissions in /home/ are secure" $points
}

