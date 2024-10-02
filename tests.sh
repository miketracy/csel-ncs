#### helpers!
#    all helpers should return numeric return codes by echoing a
#    value as the last line before the function returns.
#
#    calling convention would be:
#      ret=$(helper_name arg [arg]...)
#    and testing the $ret for the return value
#
# pass $packagename
# return:
#   2 = not installed
#   1 = installed and not upgradble
#   0 = installed and upgradable
package_upgradable () {
#  debug "called package_upgradable $1"
  ret=$(package_installed $1)
  if [[ $ret -eq 1 ]]; then
    qret=2
  elif [[ $ret -eq 0 ]]; then
#    debug "package_upgradable $1 : $ret : $?"
    ret=$(apt list --upgradable 2>/dev/null | grep ^$1)
    qret=1
  else
    qret=0
  fi
  echo $qret
}

#pass $packagename
package_installed () {
# this is as hacky as it gets and I hate it
  ret=$(tail -1 <(dpkg -l $1 2>&1) |\
     tr -s " " | cut -f3 -d" " | grep -E -o -e "packages" -e "<none>")
  if [[ $? -eq 0 ]]; then
    qret=1
  else
    qret=0
  fi
#  debug "package_installed $1 $qret"
  echo $qret
}

# pass $file
file_exists () {
  file=$1
  [[ -f $file ]]
  echo $?
}

uprades_waiting () {
  updates=$(apt list --upgradable 2>/dev/null | wc -l)
  echo $updates
}

ufw_is_active () {
  val=$(ufw status | grep -E -o "Status: active")
  if [[ $val == "Status: active" ]]; then
    echo 0
  else
    echo 1
  fi
}

# pass pipe delimited field expressing firewall rule
# e.g.: 22/tcp|ALLOW IN|Anywhere
# there's simply got to be a better way -ed
ufw_rule_exists () {
  rule=$1
  debug $rule
  test=$(ufw status numbered | sed 's/\ \ \ */|/g' | cut -f2 -d] | sed 's/^[[:blank:]]*//g' | grep -E -o '$rule')
  debug $test
  echo $?
}

# pass $file $pattern
has_line () {
  :
}

# pass $file $key $compare $value
# super hacky but works on fields of the form
# KEY  VAL
# KEY=VAL
has_value () {
  file=$1
  key=$2
  compare=$3
  value=$4
#  rval=$(grep -E -o -e ${key}=[0-9]+ -e ${key}\s+[0-9]+ $file) # | cut -f2 -d=)
  rval=$(grep -E -o ${key}.+\[0-9\]+ $file)
  rval=$(echo $rval | tr -s " " | sed 's/[[:blank:]]/=/')
  rval=$(echo $rval | cut -f2 -d=)
  debug "$file $key $compare $value ###$rval###"
  qret=101
  case $compare in
    "lt") [[ $value -lt $rval ]] && qret=0;;
    "gt") [[ $value -gt $rval ]] && qret=0;;
    "le") [[ $value -le $rval ]] && qret=0;;
    "ge") [[ $value -ge $rval ]] && qret=0;;
    "eq") [[ $value -eq $rval ]] && qret=0;;
    "ne") [[ $value -ne $rval ]] && qret=0;;
    *) qret=127;;
  esac
  debug "ret=###$qret###"
  echo $qret
}

# for lightdm config files
# pass $directory $pattern
has_line_any_file () {
  :
}

# pass $username
admin_exists () {
  ret=$(getent group sudo | grep -E -o $1)
  echo $?
}

# pass $username
user_exists () {
  ret=$(getent passwd $1)
  echo $?
}

# pass $groupname
group_exists () {
  ret=$(getent group $1)
  echo $?
}

# pass $servicename
service_active () {
  ret=$(systemctl is-active $1)
  echo $?
}

# pass $group $user
user_in_group () {
  ret=$(getent group $1 | grep -E -o $2)
  echo $?
}

# pass $user $plaintext
password_is () {
  user=$1
  ptext=$2
  field=$(getent shadow $user | cut -f2 -d:)
  salt=$(getent shadow $user | cut -f2 -d: | sed 's/\$[^\$]*$//')
  # not using this but I learned this so you can too
  hash=$(getent shadow $user | cut -f2 -d:)
  hash=${hash##*$} 
  [[ $hash == "" ]] && return 127
  cmp=$(mkpasswd -S $salt $ptext)
  if [[ "$cmp" == "$field" ]]; then
    echo 0
  else
    echo 1
  fi
}
