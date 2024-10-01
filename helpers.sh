#!/usr/bin/env bash
# debug echo
debug () {
  if [[ $debug -eq 0 ]]; then
    echo "$@" >&2
  fi
}

# hack to create a global variable with an array parsed from a csv list
# global: __list
# pass: csv string (no spaces between entries)
csv2arr () {
  line=$1
  debug "${FUNCNAME} line = ${line}"
  readarray -d ',' -t __list < <(printf $line) # use printf to prevent trailing \n
}

add_possible_points () {
  points=$1
  [[ points -ge 0 ]] && ((possible_points += points))
}
# configure users in setup
configure_users () {
  apt install whois # make sure we have mkpasswd
  for user in "${!users_config[@]}"; do
    # dumbest way to handle a struct ever
    # and I hate bash for true=0 and false=1
    csv2arr "${users_config[$user]}"
    creat=${__list[0]}
    ptype=${__list[1]}
    pword=${__list[2]}
    is_auth=${__list[3]}
    is_admin=${__list[4]}
    sonly=${__list[5]}
    group=${__list[6]}
    debug "${FUNCNAME} ${creat} | ${user} | ${ptype} | ${pword} | ${is_auth} | ${is_admin} | ${sonly} | ${group} "
    if [[ "$user" == "$SUDO_USER" ]]; then
      debug "FATAL: attemted to delete current user"
      exit
    fi
    userdel -r $user
    rm -rf /home/$user
    if [[ $creat == 0 ]]; then
      useradd -m $user
      chown -R $user:$user /home/${user}
      chmod 0750 /home/${user}
      if [[ $ptype == "plain" ]]; then
        usermod -p $pword $user
      else
        usermod -p $(mkpasswd -m $ptype $pword) $user
      fi
      [[ $is_admin -eq 1 ]] && gpasswd -a $user sudo
      [[ $sonly -eq 1 ]] && sed '/^${user}.*/d' /etc/passwd
    else
      debug "${FUNCNAME} SKIPPING ${user}"
    fi
  done
}

# pass $packagename
# return:
#   2 = not installed
#   1 = installed and not upgradble
#   0 = installed and upgradable
is_upgradable () {
  $(is_installed $1)
  insret=$?
  [[ $insret -eq 1 ]] && return 2
  ret=$(apt list --upgradable 2>/dev/null | grep ^$1)
  upgret=$?
  return $upgret
}

#pass $packagename
is_installed () {
# this is as hacky as it gets and I hate it
  ret=$(tail -1 <(dpkg -l $1 2>&1) |\
     tr -s " " | cut -f3 -d" " | grep -E -o -e "packages" -e "<none>")
  if [[ $? -eq 0 ]]; then
    return 1
  else
    return 0
  fi
#  echo $?
}

# pass $username
exist_admin () {
  ret=$(getent group sudo | grep -E -o $1)
  echo $?
}

# pass $username
exist_user () {
  ret=$(getent passwd $1)
  echo $?
}

# pass $groupname
exist_group () {
  ret=$(getent group $1)
  echo $?
}

# pass $servicename
exist_service () {
  ret=$(systemctl is-active $1)
  echo $?
}

# pass $group $user
exist_user_in_group () {
  ret=$(getent group $1 | grep -E -o $2)
  echo $?
}

footer="
      <hr />
      <div align='center'>
        Developed for Neotoma Composite Squadron, Civil Air Patrol<br />
        by some guy who was really bored one night
      </div>
    </body>
  </html>"

write_header () {
  file=$1
  points=$2
  header="
  <!doctype html>
     <html>
      <head>
        <title>Super Simple Score Report</title>
        <meta http-equiv='refresh' content='60'>
      </head>
      <body style='font-family:monospace;font-size:12pt;background-color:lightgray;'>
        <div align='center'><h2>Super Simple Score Report</h2></div>
        <div align='center'><h3>Your score: ${2} out of ${possible_points}</h3></div>
        <div align='center'>$(date)</div><hr /><br />"
  echo $header > $1
}
write_html () {
  file="${location}/scoring_report.html"
  write_header "${file}" "${total_points}"
#  echo $header > $file
  lines=("$@")
  for line in "${lines[@]}"; do
    echo $line
    echo $line >> $file
  done
  echo $footer >> $file
  cp $file /mnt/z/
}
#---- END helpers.sh
