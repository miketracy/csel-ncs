

cpuser="campy"
location="/home/${cpuser}/Desktop/"

# ablist where a = ugasz (user,group,application,service,administrator)
#              b = acn (authorized,create,not authorized)
# don't ever mess with campy
ualist="barry,carry,garry,harry,jerry,kerri,larry,mary,perry,terry" #,jennifer"
uclist="jennifer"
unlist="inky,pinky,blinky,clyde"
gclist="warriors,noobs"
aalist="firefox,thunderbird,ufw,openssh-server"
aclist="ruby,x2goserver,openssh-server,ufw"
anlist="nginx,nginx-common,nginx-core,wireshark,vsftpd,aisleriot,qbittorrent,ophcrack"
salist="sshd"
snlist="nginx,vsftpd"
zalist="barry,larry"
znlist="garry"
ppasswd="kerri,sohappy" # user with plaintext password
ushadow=""
spasswd="Pat42#ncs"

contraband_location="/home/garry/Music/"

# in setup, this will set each user's password to the indicated type and value
# [username]="create,type,password,is_auth,is_admin,shadow_only,group membership
declare -A users_config=(
  [barry]="0,yescrypt,${spasswd},1,1,0,warriors"
  [carry]="0,yescrypt,${spasswd},1,1,0,"
  [garry]="0,yescrypt,${spasswd},1,1,0,"
  [harry]="0,plain,iamapassword,1,0,0,"
  [jerry]="0,sha-512,${spasswd},1,0,0,"
  [kerri]="0,sha-512,${spasswd},1,0,0,"
  [larry]="0,yescrypt,${spasswd},1,1,0,"
  [mary]="0,md5,${spasswd},1,0,0,"
  [perry]="0,sha-256,${spasswd},1,0,0,"
  [terry]="0,plain,derpydoo,1,0,0,"
  [inky]="0,yescrypt,${spasswd},0,0,0,"
  [pinky]="0,yescrypt,${spasswd},0,0,0,"
  [blinky]="0,yescrypt,${spasswd},0,0,0,"
  [clyde]="0,yescrypt,${spasswd},0,0,0,"
  [haxor]="0,plain,pwnt,0,0,1,"
  [jennifer]="1,yescrypt,${spasswd},0,0,0,warriors"
)

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
  [points]=3
  [text]="Package has been updated"
  [list]="${aalist}"
)

declare -A apps_install=(
  [points]=3
  [text]="Required package has been installed"
  [list]="${aclist}"
)

declare -A svcs_unauth=(
  [points]=6
  [text]="Unauthorized servive is not running"
  [list]="${snlist}"
)

declare -A apps_unauth=(
  [points]=3
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
  [points]=3
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

declare -A forensics_questions
forensics_questions=(
  [questions]="forensics-1.txt,forensics-2.txt"
)

declare -A forensics_answers
forensics_answers=(
[points]=11
[text]="Forensics question correct"
['forensics-1.txt']="/home/garry/Music/"
['forensics-2.txt']="131f95c51cc819465fa1797f6ccacf9d494aaaff46fa3eac73ae63ffbdfd8267"
)
