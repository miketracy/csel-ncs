# globals
declare -a __list # global variable hack for csv2arr
declare -a results
total_points=0
possible_points=0
debug=0

#tktk refactor
check_user_in_group () {
  declare -n struct=users_in_group
  csv2arr "${struct[list]}"
  group="${struct[name]}"
  for user in "${__list[@]}"; do
    add_possible_points ${struct[points]}
    ret=$(exist_user_in_group $group $user)
    if [[ $ret -eq 0 ]]; then
      record "User $user has been added to $group" ${struct[points]}
    fi
  done
}

check_group_add () {
  declare -n struct=groups_add
  csv2arr "${struct[list]}"
  for group in "${__list[@]}"; do
    add_possible_points ${struct[points]}
    debug "($FUNCNAME) group = $group"
    ret=$(exist_group $group)
    if [[ $ret -eq 0 ]]; then
      record "${struct[text]}: ${group}" ${struct[points]}
    fi
  done
}

check_auth_users () {
  declare -n struct=users_auth
  csv2arr "${struct[list]}"
  for user in "${__list[@]}"; do
#    add_possible_points ${struct[points]}
    ret=$(exist_user $user)
    if [[ $ret -ne 0 ]]; then
      record "${struct[text]}: $user" ${struct[points]}
    fi
  done
}

check_auth_admins () {
  declare -n struct=admins_auth
  csv2arr "${struct[list]}"
  for user in "${__list[@]}"; do
#    add_possible_points ${struct[points]}
    ret=$(exist_admin $user)
    if [[ $ret -ne 0 ]]; then
      record "${struct[text]}: $user" ${struct[points]}
    fi
  done
}

check_unauth_users () {
  declare -n struct=users_unauth
  csv2arr "${struct[list]}"
  for user in "${__list[@]}"; do
    add_possible_points ${struct[points]}
    ret=$(exist_user $user)
    if [[ $ret -ne 0 ]]; then
      record "${struct[text]}: $user" ${struct[points]}
    fi
  done
}

check_unauth_admins () {
  declare -n struct=admins_unauth
  csv2arr "${struct[list]}"
  for user in "${__list[@]}"; do
    add_possible_points ${struct[points]}
    ret=$(exist_admin $user)
    if [[ $ret -ne 0 ]]; then
      record "${struct[text]}: $user" ${struct[points]}
    fi
  done
}

check_critical_apps () {
  declare -n struct=apps_auth
  csv2arr "${struct[list]}"
  for app in "${__list[@]}"; do
#    add_possible_points ${struct[points]}
    ret=$(is_installed $app)
    insret=$?
    if [[ $insret -ne 0 ]]; then
      record "${struct[text]}: $app" ${struct[points]}
    fi
  done
}

check_apps_upgrade () {
  declare -n struct=apps_upgrade
  csv2arr "${struct[list]}"
  for app in "${__list[@]}"; do
    add_possible_points ${struct[points]}
    ret=$(is_upgradable $app)
    upgret=$?
    if [[ $upgret == 1 ]]; then
      record "${struct[text]}: $app" ${struct[points]}
    fi
  done
}

check_contraband () {
  declare -n struct=contraband_files
  loc="${struct[location]}"
  csv2arr "${struct[files]}"
  for file in "${__list[@]}"; do
    add_possible_points ${struct[points]}
    if [[ ! -f ${loc}/${file} ]]; then
      record "${struct[text]}: $file" ${struct[points]}
    fi
  done
}

check_apps_install () {
  declare -n struct=apps_install
  csv2arr "${struct[list]}"
  for app in "${__list[@]}"; do
    add_possible_points ${struct[points]}
    ret=$(is_installed $app)
    insret=$?
    if [[ $insret == 0 ]]; then
      record "${struct[text]}: $app" ${struct[points]}
    fi
  done
}

check_apps_unauth () {
  declare -n struct=apps_unauth
  csv2arr "${struct[list]}"
  for app in "${__list[@]}"; do
    add_possible_points ${struct[points]}
    ret=$(is_installed $app)
    insret=$?
    if [[ $insret == 1 ]]; then
      record "${struct[text]}: $app" ${struct[points]}
    fi
  done
}

check_forensics () {
  declare -n struct=forensics_answers
  for file in "${!struct[@]}"; do
    add_possible_points ${struct[points]}
    if [[ -f "${location}/${file}" ]]; then
      ans=$(grep -E -o ANSWER.* ${location}/${file} | sed 's/ANSWER:\ //g')
      if [[ $ans == "${struct["$file"]}" ]]; then
        record "${struct[text]}: ${file}" ${struct[points]}
      fi
    fi
  done
}
