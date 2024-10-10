# facile check for presence of harry reverse shell crontab
check_reverse_shell () {
  points=11
  add_possible_points $points
  txt=$(crontab -l -u harry)
  ret=$?
  [[ $ret -eq 1 ]] && record "reverse shell removed from crontab" $points
}

# facile check for suid file from setup
check_suid_files () {
  debug "NOT IMPLEMENTED"
  points=5
  add_possible_points $points
  [[ ! -f /var/log/.harmless ]] && record "setuid executable removed" $points
}

# check for secure permissions in /home/
check_home_perms () {
  points=2
  add_possible_points $points
  ret=$(ls -l /home/ | grep -e total -e ^drwxr-x--- -v | wc -l)
  [[ "$ret" -eq 0 ]] && record "Permissions in /home/ are secure" $points
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

