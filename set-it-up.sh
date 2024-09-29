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

# special case rm ufw
apt purge ufw -y
eapt autoremove -y

# add users
csv2arr "${ualist}"
for user in "${__list[@]}"; do
  userdel $user
  useradd $user
  mkdir -p /home/${user}
  chown -R $user:$user /home/${user}
  chmod 0750 /home/${user}
done

csv2arr "${unlist}"
for user in "${__list[@]}"; do
  userdel $user
  useradd $user
  mkdir -p /home/${user}
  chown -R $user:$user /home/${user}
  chmod 0750 /home/${user}
done

# add groups

# add packages
csv2arr "${anlist}"
for pkg in "${__list[@]}"; do
  apt install $pkg -y
done

# remove packages
csv2arr "${aclist}"
for pkg in "${__list[@]}"; do
  apt purge $pkg -y
  apt autoremove -y
done

# special case downgrade thunderbird
apt --allow-downgrades install thunderbird=1:91.8.0+build2-0ubuntu1 -y

# rm packages

# add administrators
csv2arr "${zalist}"
for user in "${__list[@]}"; do
  gpasswd -a $user sudo
done

csv2arr "${znlist}"
for user in "${__list[@]}"; do
  gpasswd -a $user sudo
done

# install orig files
cp -f orig/common-* /etc/pam.d/
cp -f orig/login.defs /etc/
cp -f orig/sysctl.conf /etc/

# make some music
EICAR='X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
mkdir -p /home/garry/Music/
echo $EICAR > /home/garry/Music/some-song.mp3
echo $EICAR > /home/garry/Music/some-movie.mp4
echo $EICAR > /home/garry/Music/bad-image.png
