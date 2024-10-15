
debug () {
  if [[ $debug -eq 0 ]]; then
    echo "DEBUG[${FUNCNAME[1]}] $@" >&2
  fi
}

record () {
  txt=$1
  local rpoints=$2
  debug "$1 -- $2"
  if [[ $rpoints -lt 1 ]]; then
    style='style="color:darkred"'
  else
    style='style="color:black"'
  fi
  if [[ $debug -eq 0 ]]; then
    results+=("<span ${style}>[${FUNCNAME[1]}] ${txt} -- ${rpoints} points</span>
<br />")
  else
    results+=("<span ${style}>${txt} -- ${rpoints} points</span><br />")
  fi
  ((total_points += $rpoints))
}

fatal () {
    echo "FATAL[${FUNCNAME[1]}] $@" >&2
    exit 127
}
# score_it pass configuration hash
# score_list ()
# score_location ()
score_it () {
  local -n hash=$1
  local rpoints="${hash[points]}"
  type=$(echo "${hash[type]}" | sed 's/_not//; t; q1')
  not=$?
  if [[ -v "hash[file]" ]]; then
    debug "hash[file] exists"
#    ret=$($type "${hash[file]" "${hash[list]")
#  else
  fi
  debug "${FUNCNAME[1]} $rpoints $type $not"
}

# pass: array_name [delimiter] csv
csv2arr () {
  local -n retarr=$1
  if [[ -z $3 ]]; then
    delimiter=","
    line=$2
  else
    delimiter=$2
    line=$3
  fi
  debug "csv2arr[${FUNCNAME[1]}] $retarr delimiter = ${delimiter} line = ${line}"
  readarray -d $delimiter -t retarr < <(printf $line) # use printf to prevent trailing \n
}

get_shadow_entry () {
  user=$1
  local -n retent=entry
  local -a retarr
  readarray -d : -t retarr < <(getent shadow $user)
  retent[user]=${retarr[0]}
  retent[password]=${retarr[1]}
  retent[algo]=$(echo "${retent[password]}" | sed 's/^\(\$.\$\).*/\1/')
  retent[salt]=$(echo "${retent[password]}" | sed 's/\$[^\$]*$//')
  retent[hash]=${retent[password]##*$}
  retent[dlchange]=${retarr[2]}
  retent[minage]=${retarr[3]}
  retent[maxage]=${retarr[4]}
  retent[pwarn]=${retarr[5]}
  retent[pwinac]=${retarr[6]}
  retent[acctexp]=${retarr[7]}
  retent[reserved]=${retarr[8]}
}

# pass $username
get_user_entry () {
  user=$1
  local -n hash=users_config
  local -n retent=entry
  local list
  csv2arr list "${hash[$user]}"
  retent[creat]=${list[0]}
  retent[algo]=${list[1]}
  retent[passwd]=${list[2]}
  retent[is_auth]=${list[3]}
  retent[is_admin]=${list[4]}
  retent[shadow_only]=${list[5]}
  retent[group]=${list[6]}

  debug "user = $user | entry = ${entry[@]} | ${hash[$user]}"
}

add_possible_points () {
  local rpoints=$1
  debug "POSSIBLE: [${FUNCNAME[1]}] -- $rpoints points"
  [[ rpoints -ge 0 ]] && ((possible_points += $rpoints))
}

# configure users in setup
configure_users () {
  apt install whois # make sure we have mkpasswd
  for user in "${!users_config[@]}"; do
    # dumbest way to handle a struct ever
    # and I hate bash for true=0 and false=1
    local list
    csv2arr "list" "${users_config[$user]}"
    creat="${list[0]}"
    ptype="${list[1]}"
    pword="${list[2]}"
    is_auth="${list[3]}"
    is_admin="${list[4]}"
    sonly="${list[5]}"
    group="${list[6]}"
    debug "${FUNCNAME[1]} ${creat} | ${user} | ${ptype} | ${pword} | ${is_auth} | ${is_admin} | ${sonly} | ${group} "
    if [[ "$user" == "$SUDO_USER" ]]; then
      fatal "attemted to delete current user"
    fi
    userdel -r $user
    rm -rf /home/$user
    rm /var/mail/$user
    if [[ $creat == 0 ]]; then
      debug "creating $user"
      delgroup $user
      useradd -m $user
      chown -R $user:$user /home/${user}
      chmod 0750 /home/${user}
      if [[ $ptype == "plain" ]]; then
        usermod -p $pword $user
      else
        usermod -p $(mkpasswd -m $ptype $pword) $user
      fi
      [[ $is_admin -eq 1 ]] && gpasswd -a $user sudo
      if [[ $sonly -eq 1 ]]; then
        sed -i "/^${user}.*/d" /etc/passwd
      fi
    else
      debug "${FUNCNAME[1]} SKIPPING ${user}"
    fi
  done
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
  local file=$1
  local rpoints=$2
  header="
  <!doctype html>
     <html>
      <head>
        <title>Super Simple Score Report</title>
        <meta http-equiv='refresh' content='60'>
      </head>
      <body style='font-family:monospace;font-size:12pt;background-color:lightgray;'>
        <div align='center'><h2>Super Simple Score Report</h2></div>
        <div align='center'><h3>Your score: ${rpoints} out of ${possible_points}</h3></div>
        <div align='center'>$(date)</div><hr /><br />"
  echo $header > $file
}
write_html () {
  file="${location}/scoring_report.html"
  write_header "${file}" "${total_points}"
  lines=("$@")
  for line in "${lines[@]}"; do
    echo $line >> $file
  done
  echo $footer >> $file
  cp $file /mnt/z/
}
