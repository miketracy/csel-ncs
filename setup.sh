#!/usr/bin/env bash

# must add user jennifer
# must add group warriors
# must add users jennifer,barry to warriors
# must add jennifer to warriors

uid=`id -g`

if [ "$uid" != "0" ]; then
  echo "run script with sudo"
  echo "sudo ${0}"
  exit
fi

source ./config.sh
source ./helpers.sh

declare -a __list

# add groups
declare -n list=groups_create_list
for group in "${list[@]}"; do
  delgroup $group
done

# add packages
declare -n list=apps_unauth_list
for pkg in "${list[@]}"; do
  apt install $pkg -y
done

# remove packages
declare -n list=apps_critical_list
for pkg in "${list[@]}"; do
  apt purge $pkg -y
  apt autoremove -y
done

declare -n list=apps_install_list
for pkg in "${list[@]}"; do
  apt purge $pkg -y
  apt autoremove -y
done

# special case downgrade thunderbird
apt --allow-downgrades install thunderbird=1:91.8.0+build2-0ubuntu1 -y

# add administrators
csv2arr "${zalist}"
for user in "${__list[@]}"; do
  gpasswd -a $user sudo
done

csv2arr "${znlist}"
for user in "${__list[@]}"; do
  gpasswd -a $user sudo
done

# set up users
configure_users

# install orig files
cp -f orig/common-* /etc/pam.d/
cp -f orig/login.defs /etc/
cp -f orig/sysctl.conf /etc/

echo "install forensics questions"
declare -n list="${forensics_questions[questions]}"
for file in "${list[@]}"; do
  cp -f ./forensics/$file $location
  chown ${cpuser}:${cpuser} ${location}/${file}
  chmod 0644 ${location}/${file}
done

# make some music
EICAR='X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
declare -n hash=contraband_files
location="${hash[location]}"
declare -n list="${hash[files]}"
mkdir -p $location
for file in "${list[@]}"; do
  echo $EICAR > ${location}/${file}
done

# get rid of cracklib
apt purge libpam-cracklib
apt autoremove -y
