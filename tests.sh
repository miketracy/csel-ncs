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
  ret=$(package_installed $1)
  qret=127
  if [[ $ret -eq 1 ]]; then
    qret=2
  else
    ret=$(apt list --upgradable 2>/dev/null | grep ^$1)
    if [[ $? -eq 1 ]]; then
      qret=1
    else
      qret=0
    fi
  fi
  debug "$1 $qret"
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
  ter=$(which ufw)
  [[ $? -ne 0 ]] && return 127
  rule=$1
  test=$(ufw status numbered | sed 's/\ \ \ */|/g' | cut -f2 -d] | sed 's/^[[:blank:]]*//g' | grep -o "$rule")
  ret=$?
  debug "$rule ## $test"
  echo $ret
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
  debug "???? $file $key $compare $value"
#  rval=$(grep -E -o -e ${key}=[0-9]+ -e ${key}\s+[0-9]+ $file) # | cut -f2 -d=)
#  rval=$(grep -E -o ${key}\[\=\s]+\[0-9\]+ $file)
  rval=$(grep -E -o "${key}(\s+|=)+[0-9a-zA-Z]+" $file)
#  rval=$(grep -E -o "${key}(\s+|=)+[0-9]+" $file)
  rret=$?
  [[ "$?" -ne 0 ]] && return 127
  debug "[$rret] orig $rval"
  rval=$(echo $rval | sed 's/\s*=\s*/=/')                  # spaces around equal
  rval=$(echo $rval | tr -s " " | sed 's/[[:blank:]]/=/')  # space to equal
  debug "spaces to = $rval"
  rval=$(echo $rval | cut -f2 -d=)
  debug "$value $compare $rval"
  qret=1
  # add string compare
  case $compare in
    "lt") [[ $rval -lt $value ]] && qret=0;;
    "gt") [[ $rval -gt $value ]] && qret=0;;
    "le") [[ $rval -le $value ]] && qret=0;;
    "ge") [[ $rval -ge $value ]] && qret=0;;
    "eq") [[ $rval -eq $value ]] && qret=0;;
    "ne") [[ $rval -ne $value ]] && qret=0;;
    "!=") [[ "$rval" != "$value" ]] && qret=0;;
    "==") [[ "$rval" == "$value" ]] && qret=0;;
    *) qret=127;;
  esac
  debug "$file $key $compare $value $qret"
  return $qret
}

# for lightdm config files
# pass $directory $pattern
has_line_any_file () {
  : #tktk
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
  ret=$?
  debug "$1 $ret"
  echo $ret
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
  cmp=$(mkpasswd -S "$salt" "$ptext")
  if [[ "$cmp" == "$field" ]]; then
    echo 0
  else
    echo 1
  fi
}

# pass $file $perms [octal e.g. 750]
has_permissions () {
  : # stat -c%a /home/garry
}
