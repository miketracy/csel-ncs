#!/usr/bin/env bash

location="/home/campy/Desktop/"
total_points=0
declare -a results

#declare -A admins_auth
#declare -A admins_unauth
#declare -A apps_required
#declare -A apps_remove
# lightdm settings

# ablist where a = ugasz (user,group,application,service,administrator)
#              b = acn (authorized,create,not authorized)
ualist="campy,barry,carry,garry,harry,jerry,kerri,larry,mary,perry,terry" #,jennifer"
uclist="jennifer"
unlist="inky,pinky,blinky,clyde"
gclist="warriors,noobs"
aalist="firefox,thunderbird,ufw"
aclist="ruby,x2goserver,openssh-server"
anlist="nginx,nginx-common,nginx-core,wireshark,vsftpd,aisleriot,qbittorrent,ophcrack"
salist="sshd"
snlist="nginx,vsftpd"
zalist="campy,barry,larry"
znlist="garry"
contraband_location="/home/garry/Music/"

# special case. these users belong in this group.
declare -A addtogroup
addtogroup=(
  [points]=5
  [name]="warriors"
  [list]="jennifer,barry,removeme"
)

declare -A contraband_files=(
  [points]=3
  [text]="Contraband file has been removed"
  [location]="${contraband_location}"
  [files]="bad-image.png,some-movie.mp4,some-song.mp3"
)

declare -A apps_upgrade=(
  [points]=4
  [text]="Package has been updated"
  [list]="${aalist}"
)

declare -A apps_install=(
  [points]=4
  [text]="Required package has been installed"
  [list]="${aclist}"
)

declare -A svcs_unauth=(
  [points]=6
  [text]="Unauthorized servive is not running"
  [list]="${snlist}"
)

declare -A apps_unauth=(
  [points]=6
  [text]="Unauthorized application has been removed"
  [list]="${anlist}"
)

declare -A svcs_auth=(
  [points]=-6
  [text]="Critical service is not running"
  [list]="${salist}"
)

declare -A apps_auth=(
  [points]=-6
  [text]="Critical application has been removed"
  [list]="${aalist}"
)

declare -A admins_auth=(
  [points]=-6
  [text]="Authorized administrator has been removed"
  [list]="${zalist}"
)

declare -A admins_unauth=(
  [points]=6
  [text]="Unauthorized administrator has been removed"
  [list]="${znlist}"
)

declare -A users_auth
users_auth=(
  [points]=-6
  [text]="Authorized user has been removed"
  [list]="${ualist}"
)

declare -A users_unauth
users_unauth=(
  [points]=6
  [text]="Unauthorized user has been removed"
  [list]="${unlist}"
)

declare -A groups_add
groups_add=(
  [points]=4
  [text]="Required group has been created"
  [list]="${gclist}"
)

declare -A policy
policy=(
  [points]=5
  [updates]="System updates are current"
  [pwage]="A secure password age exists"
  [pwquality]="Password quality has been configured"
  [pwhistory]="A secure password history has been configured"
  [pwminlen]="A secure password minimum length exists"
  [permitroot]="Root logins via ssh have been disabled"
  [pwnullok]="Null password logins are disabled"
  [fwactive]="UFW firewall is enabled and running"
)
