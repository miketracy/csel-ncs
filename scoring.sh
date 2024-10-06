
# check user's password has been changed
check_password_change () {
  local -n hash=password_change
  local -n list="${hash[list]}"
  for user in "${list[@]}"; do
    add_possible_points ${hash[points]}
    local -A entry=()
    get_user_entry $user
    ret=$(password_is $user "${entry[passwd]}")
    if [[ $ret -ne 0 ]]; then
      record "${hash[text]}: $user" ${hash[points]}
    fi
  done
}

check_user_in_group () {
  declare -n hash=users_in_group
  declare -n list="${hash[list]}"
  group="${hash[name]}"
  for user in "${list[@]}"; do
    add_possible_points ${hash[points]}
    ret=$(user_in_group $group $user)
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
    ret=$(group_exists $group)
    if [[ $ret -eq 0 ]]; then
      record "${hash[text]}: ${group}" ${hash[points]}
    fi
  done
}

check_users_auth () {
  declare -n hash=users_auth
  declare -n list="${hash[list]}"
  for user in "${list[@]}"; do
#    add_possible_points ${hash[points]}
    ret=$(user_exists $user)
    if [[ $ret -ne 0 ]]; then
      record "${hash[text]}: $user" ${hash[points]}
    fi
  done
}

check_admins_auth () {
  declare -n hash=admins_auth
  declare -n list="${hash[list]}"
  for user in "${list[@]}"; do
#    add_possible_points ${hash[points]}
    ret=$(admin_exists $user)
    if [[ $ret -ne 0 ]]; then
      record "${hash[text]}: $user" ${hash[points]}
    fi
  done
}

check_users_unauth () {
  declare -n hash=users_unauth
  declare -n list="${hash[list]}"
  for user in "${list[@]}"; do
    add_possible_points ${hash[points]}
    ret=$(user_exists $user)
    if [[ $ret -ne 0 ]]; then
      record "${hash[text]}: $user" ${hash[points]}
    fi
  done
}

check_admins_unauth () {
  declare -n hash=admins_unauth
  declare -n list="${hash[list]}"
  for user in "${list[@]}"; do
    add_possible_points ${hash[points]}
    ret=$(admin_exists $user)
    if [[ $ret -ne 0 ]]; then
      record "${hash[text]}: $user" ${hash[points]}
    fi
  done
}

check_services_critical () {
  declare -n hash=services_critical
  declare -n list="${hash[list]}"
  for svc in "${list[@]}"; do
#    add_possible_points ${hash[points]}
    ret=$(service_active $svc)
    if [[ $ret -ne 0 ]]; then
      record "${hash[text]}: $svc" ${hash[points]}
    fi
  done
}

check_services_unauth () {
  declare -n hash=services_unauth
  declare -n list="${hash[list]}"
  for svc in "${list[@]}"; do
    add_possible_points ${hash[points]}
    ret=$(service_active $svc)
    if [[ $ret -ne 0 ]]; then
      record "${hash[text]}: $svc" ${hash[points]}
    fi
  done
}

check_services_installed () {
  declare -n hash=services_installed
  declare -n list="${hash[list]}"
  for svc in "${list[@]}"; do
    add_possible_points ${hash[points]}
    ret=$(service_active $svc)
    if [[ $ret -eq 0 ]]; then
      record "${hash[text]}: $svc" ${hash[points]}
    fi
  done
}

check_packages_critical () {
  declare -n hash=packages_critical
  declare -n list="${hash[list]}"
  for app in "${list[@]}"; do
#    add_possible_points ${hash[points]}
    ret=$(package_installed $app)
    if [[ $ret -ne 0 ]]; then
      record "${hash[text]}: $app" ${hash[points]}
    fi
  done
}

check_packages_upgrade () {
  declare -n hash=packages_upgrade
  declare -n list="${hash[list]}"
  for app in "${list[@]}"; do
    add_possible_points ${hash[points]}
    ret=$(package_upgradable $app)
    if [[ $ret -eq 1 ]]; then
      record "${hash[text]}: $app" ${hash[points]}
    fi
  done
}

check_contraband () {
  declare -n hash=contraband_files
  loc="${hash[location]}"
  declare -n list="${hash[files]}"
  for file in "${list[@]}"; do
    add_possible_points "${hash[points]}"
    debug "${loc}/${file}"
    if [[ ! -f "${loc}/${file}" ]]; then
      record "${hash[text]}: $file" "${hash[points]}"
    fi
  done
}

check_packages_installed () {
  declare -n hash=packages_installed
  declare -n list="${hash[list]}"
  for app in "${list[@]}"; do
    add_possible_points ${hash[points]}
    ret=$(package_installed $app)
    if [[ $ret -eq 0 ]]; then
      record "${hash[text]}: $app" ${hash[points]}
    fi
  done
}

check_packages_unauth () {
  declare -n hash=packages_unauth
  declare -n list="${hash[list]}"
  for app in "${list[@]}"; do
    add_possible_points ${hash[points]}
    ret=$(package_installed $app)
    if [[ $ret -eq 1 ]]; then
      record "${hash[text]}: $app" ${hash[points]}
    fi
  done
}

check_forensics () {
  declare -n hash=forensics_answers
  for file in "${!hash[@]}"; do
    if [[ -f "${location}/${file}" ]]; then
      add_possible_points ${hash[points]}
      ans=$(grep -E -o ANSWER.* ${location}/${file} | sed 's/ANSWER:\ //g')
      if [[ $ans == "${hash["$file"]}" ]]; then
        record "${hash[text]}: ${file}" ${hash[points]}
      fi
    fi
  done
}
