
#### modules to include
#    forensics questions and system updates run by default
declare -A modules=(
  [negative]=0     # include negative points
  [users]=0        # include all user and group membership checks
  [policy]=0       # include all policy checks
  [stig]=0         # include all checks developed from STIG research
)

#### setup varibles
#
cpuser=campy #your currently logged in user
location="/home/${cpuser}/Desktop/"
spasswd="Pat42#ncs"


#### lists for checks

#### users and groups
#
declare -a users_create_list=(
  "jennifer"
)
declare -a users_unauth_list=(
  "inky" "pinky" "blinky" "clyde"
)

declare -a admins_auth_list=(
  "barry" "larry"
)

declare -a admins_unauth_list=(
  "garry" "carry"
)

declare -a groups_create_list=(
  "warriors" "noobs"
)

#### packages and services
#
declare -a packages_upgrade_list=(
  "firefox" "thunderbird" "ufw" "openssh-server"
)

declare -a packages_install_list=(
  "ruby" "x2goserver" "libpam-cracklib" "clamav"
)

declare -a packages_critical_list=(
  "openssh-server" "ufw" "auditd"
)

declare -a packages_unauth_list=(
  "wireshark" "aisleriot" "qbittorrent" "ophcrack" "telnetd"
)

declare -a services_critical_list=(
  "sshd"
)

declare -a services_installed_list=(
  "auditd" "clamav-freshclam"
)

declare -a services_unauth_list=(
  "nginx" "vsftpd"
)

#### set up all users and their group memberships
#    in setup, this will set each user's password to the indicated type and value
#    [username]="create,algo,password,is_auth,is_admin,shadow_only,group membership
declare -A users_config=(
  [barry]="0,yescrypt,z!pit3do0D4h,1,1,0,warriors"
  [larry]="0,yescrypt,fnork,1,1,0,"
  [carry]="0,yescrypt,${spasswd},1,1,0,"
  [garry]="0,yescrypt,${spasswd},1,1,0,"
  [harry]="0,plain,!,1,0,0,"
  [jerry]="0,sha-512,${spasswd},1,0,0,"
  [kerri]="0,sha-512,${spasswd},1,0,0,"
  [mary]="0,md5,${spasswd},1,0,0,"
  [perry]="0,sha-256,${spasswd},1,0,0,"
  [terry]="0,plain,!,1,0,0,"
  [inky]="0,yescrypt,${spasswd},0,0,0,"
  [pinky]="0,yescrypt,${spasswd},0,0,0,"
  [blinky]="0,yescrypt,${spasswd},0,0,0,"
  [clyde]="0,yescrypt,${spasswd},0,0,0,"
  [haxor]="0,plain,pwnt,0,0,1,"
  [jennifer]="1,yescrypt,${spasswd},0,0,0,warriors"
)


# special case. these users belong in this group.
# tktk refactor
declare -a password_change_list=(
  "larry"
)
declare -A password_change=(
  [points]=3
  [type]=password_is
  [list]=password_change_list
  [text]="Insecure password has been changed"
)

declare -a users_in_group_list=(
  "jennifer" "barry"
)
declare -A users_in_group=(
  [points]=3
  [type]=user_in_group
  [name]="warriors"
  [list]=users_in_group_list
  [text]="User has been added to group"
)

declare -a contraband_files_list=(
  "bad-image.png"
  "some-movie.mp4"
  "some-song.mp3"
)
declare -A contraband_files=(
  [points]=3
  [type]=file_exists
  [location]="/home/garry/Music/"
  [files]=contraband_files_list
  [text]="Contraband file has been removed"
)

declare -A admins_auth=(
  [points]=-10
  [type]=admin_exists_not
  [list]=admins_auth_list
  [text]="Authorized administrator has been removed"
)

declare -A admins_unauth=(
  [points]=3
  [type]=admin_exists
  [list]=admins_unauth_list
  [text]="Unauthorized administrator has been removed"
)

declare -a users_auth_list=(
  "barry" "carry" "garry" "harry" "jerry"
  "kerri" "larry" "mary" "perry" "terry"
)
declare -A users_auth=(
  [points]=-10
  [type]=user_exists_not
  [list]=users_auth_list
  [text]="Authorized user has been removed"
)

declare -A users_unauth=(
  [points]=3
  [type]=user_exists
  [list]=users_unauth_list
  [text]="Unauthorized user has been removed"
)

declare -A groups_create=(
  [points]=3
  [type]=group_exists
  [list]=groups_create_list
  [text]="Required group has been created"
)

#### files, apps and services

declare -A packages_upgrade=(
  [points]=3
  [type]=package_upgradable
  [list]=packages_upgrade_list
  [text]="Package has been updated"
)

declare -A packages_installed=(
  [points]=3
  [type]=package_installed
  [list]=packages_install_list
  [text]="Required package has been installed"
)

declare -A packages_unauth=(
  [points]=3
  [type]=package_installed_not
  [list]=packages_unauth_list
  [text]="Unauthorized application has been removed"
)

declare -A packages_critical=(
  [points]=-10
  [type]=package_installed_not
  [list]=packages_critical_list
  [text]="Critical application has been removed"
)

#tktk
declare -A services_critical=(
  [points]=-10
  [type]=service_active_not
  [list]=services_critical_list
  [text]="Critical service is not running"
)

declare -A services_unauth=(
  [points]=6
  [type]=service_active_not
  [list]=services_unauth_list
  [text]="Unauthorized service is not running"
)

declare -A services_installed=(
  [points]=6
  [type]=service_active
  [list]=services_installed_list
  [text]="Service is running"
)

#### policy
#    these scoring functions are all hardcoded in scoring_policy.sh
#    tktk refactor
declare -A policy
policy=(
  [points]=3
  [updates]="System updates are current"
  [pwage]="A secure password age exists"
  [pwquality]="Password quality has been configured"
  [pwhistory]="A secure password history has been configured"
  [pwminlen]="A secure password minimum length exists"
  [permitroot]="Root logins via ssh have been disabled"
  [pwnullok]="Null password logins are disabled"
  [fwactive]="UFW firewall is enabled and running"
  [auditd]="auditd is enabled and running"
)

#### forensics questions
#    created in setup.sh
#    tktk refactor

declare -a forensics_questions_list=(
  "forensics-1.txt"
  "forensics-2.txt"
)
declare -A forensics_questions
forensics_questions=(
  [questions]=forensics_questions_list
)

declare -A forensics_answers
forensics_answers=(
[points]=10
[text]="Forensics question correct"
['forensics-1.txt']="/home/garry/Music/"
['forensics-2.txt']="131f95c51cc819465fa1797f6ccacf9d494aaaff46fa3eac73ae63ffbdfd8267"
)
