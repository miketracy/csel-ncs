
check_user_in_group () {
  declare -n hash=users_in_group
  declare -n list="${hash[list]}"
  group="${hash[name]}"
  for user in "${list[@]}"; do
    add_possible_points ${hash[points]}
    ret=$(exist_user_in_group $group $user)
    if [[ $ret -eq 0 ]]; then
      record "User $user has been added to $group" ${hash[points]}
    fi
  done
}

check_group_add () {
  declare -n hash=groups_create
  declare -n list="${hash[list]}"
  for group in "${list[@]}"; do
    add_possible_points ${hash[points]}
    debug "($FUNCNAME) group = $group"
    ret=$(exist_group $group)
    if [[ $ret -eq 0 ]]; then
      record "${hash[text]}: ${group}" ${hash[points]}
    fi
  done
}

check_auth_users () {
  declare -n hash=users_auth
  declare -n list="${hash[list]}"
  for user in "${list[@]}"; do
#    add_possible_points ${hash[points]}
    ret=$(exist_user $user)
    if [[ $ret -ne 0 ]]; then
      record "${hash[text]}: $user" ${hash[points]}
    fi
  done
}

check_auth_admins () {
  declare -n hash=admins_auth
  declare -n list="${hash[list]}"
  for user in "${list[@]}"; do
#    add_possible_points ${hash[points]}
    ret=$(exist_admin $user)
    if [[ $ret -ne 0 ]]; then
      record "${hash[text]}: $user" ${hash[points]}
    fi
  done
}

check_unauth_users () {
  declare -n hash=users_unauth
  declare -n list="${hash[list]}"
  for user in "${list[@]}"; do
    add_possible_points ${hash[points]}
    ret=$(exist_user $user)
    if [[ $ret -ne 0 ]]; then
      record "${hash[text]}: $user" ${hash[points]}
    fi
  done
}

check_unauth_admins () {
  declare -n hash=admins_unauth
  declare -n list="${hash[list]}"
  for user in "${list[@]}"; do
    add_possible_points ${hash[points]}
    ret=$(exist_admin $user)
    if [[ $ret -ne 0 ]]; then
      record "${hash[text]}: $user" ${hash[points]}
    fi
  done
}

check_apps_critical () {
  declare -n hash=apps_critical
  declare -n list="${hash[list]}"
  for app in "${list[@]}"; do
#    add_possible_points ${hash[points]}
    ret=$(is_installed $app)
    insret=$?
    if [[ $insret -ne 0 ]]; then
      record "${hash[text]}: $app" ${hash[points]}
    fi
  done
}

check_apps_upgrade () {
  declare -n hash=apps_upgrade
  declare -n list="${hash[list]}"
  for app in "${list[@]}"; do
    add_possible_points ${hash[points]}
    ret=$(is_upgradable $app)
    upgret=$?
    if [[ $upgret == 1 ]]; then
      record "${hash[text]}: $app" ${hash[points]}
    fi
  done
}

check_contraband () {
  declare -n hash=contraband_files
  loc="${hash[location]}"
  declare -n list="${hash[files]}"
  for file in "${list[@]}"; do
    add_possible_points ${hash[points]}
    if [[ ! -f ${loc}/${file} ]]; then
      record "${hash[text]}: $file" ${hash[points]}
    fi
  done
}

check_apps_install () {
  declare -n hash=apps_install
  declare -n list="${hash[list]}"
  for app in "${list[@]}"; do
    add_possible_points ${hash[points]}
    ret=$(is_installed $app)
    insret=$?
    if [[ $insret == 0 ]]; then
      record "${hash[text]}: $app" ${hash[points]}
    fi
  done
}

check_apps_unauth () {
  declare -n hash=apps_unauth
  declare -n list="${hash[list]}"
  for app in "${list[@]}"; do
    add_possible_points ${hash[points]}
    ret=$(is_installed $app)
    insret=$?
    if [[ $insret == 1 ]]; then
      record "${hash[text]}: $app" ${hash[points]}
    fi
  done
}

check_forensics () {
  declare -n hash=forensics_answers
  for file in "${!hash[@]}"; do
    add_possible_points ${hash[points]}
    if [[ -f "${location}/${file}" ]]; then
      ans=$(grep -E -o ANSWER.* ${location}/${file} | sed 's/ANSWER:\ //g')
      if [[ $ans == "${hash["$file"]}" ]]; then
        record "${hash[text]}: ${file}" ${hash[points]}
      fi
    fi
  done
}
