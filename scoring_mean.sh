# check for presence of rootkit and its hidden directory
# no checks for the .ko or loading in /etc/modules so if they
# reboot they lose points.
check_rootkit () {
  local lpoints=11
  add_possible_points $lpoints
  ret=$(lsmod | grep cpnofind)
  if [[ $? == 0 ]]; then
    record "MISS there's a rootkit hiding a directory somewhere" 0
    return 127
  fi
  record "rootkit has been disabled" $lpoints
}

# check insecure password algorithms
# you need to expire these passwords
# so that they are changed on next login
check_shadow_insecure_hash () {
  lpoints=11
  add_possible_points $lpoints
  local -a users=( $(cat /etc/passwd | cut -f1 -d:) )
  for user in "${users[@]}"; do
    local -A entry
    get_shadow_entry $user
    if [[ "${entry[algo]}" =~ ^\$.\$ ]]; then
      if [[ "${entry[algo]}" != "\$y\$" ]]; then
        debug "$user ${entry[algo]} ${entry[dlchange]}"
        if [[ "${entry[dlchange]}" != "0" ]]; then
          record "MISS insecure password hashes stored in /etc/shadow" 0
          return 127
        fi
      fi
    fi
  done
  record "Insecure password hashes corrected in /etc/shadow" $lpoints
}

# check cron.allow is only root
check_cron_allow () {
  lpoints=5
  files=(
    "/etc/at.allow"
    "/etc/cron.allow"
  )
  for file in "${files[@]}"; do
    add_possible_points $lpoints
    ret=127
    if [[ -f $file ]]; then
      count=$(sed '/^$/d' $file | wc -l)  # has one line
      if [[ $count -eq 1 ]]; then
        rval=$(grep -E -o "root" $file)   # that line is "root"
        if [[ $? -eq 0 ]]; then
          record "$file limited to root" $lpoints
          ret=0
        fi
      fi
    fi
    if [[ $ret -ne 0 ]]; then
      record "MISS unrestricted task scheduluer" 0
    fi
  done
}

# check set world-writable files
check_world_writable () {
  lpoints=5
  add_possible_points $lpoints
  local -a files=(
    "/etc/ssh/ssh_config"
    "/etc/ssh/sshd_config"
  )
  for file in "${files[@]}"; do
    txt=$(getfacl -p $file | grep other | cut -f3 -d: | grep -E -o .w.)
    ret=$?
    if [[ $ret -eq 0 ]]; then
      record "MISS suspect world writable files" 0
      return 127
    fi
  done
  record "suspect world writable files have been fixed" $lpoints
}

# facile check for presence of harry reverse shell crontab
check_reverse_shell () {
  lpoints=11
  add_possible_points $lpoints
  txt=$(crontab -l -u harry)
  ret=$?
  if [[ $ret -eq 0 ]]; then
    record "MISS persistence mechanism" 0
    return 127
  fi
  if [[ -f "/var/spool/cron/crontabs/harry" ]]; then
    record "MISS persistence mechanism" 0
    return 127
  fi
  record "reverse shell removed from crontab" $lpoints
}

# facile check for suid file from setup
check_suid_files () {
  lpoints=5
  add_possible_points $lpoints
  if [[ ! -f /var/log/.harmless ]]; then
    record "setuid executable removed" $lpoints
  else
    record "MISS suspect suid executable" 0
  fi
}

# check for secure permissions in /home/
check_home_perms () {
  lpoints=4
  add_possible_points $lpoints
  ret=$(ls -l /home/ | grep -e total -e ^drwxr-x--- -v | wc -l)
  if [[ "$ret" -eq 0 ]]; then
    record "Permissions in /home/ are secure" $lpoints
  else
    record "MISS secure file permissions" 0
  fi
}
