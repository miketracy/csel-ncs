#!/usr/bin/env bash

uid=`id -g`
if [ "$uid" != "0" ]; then
  echo "run script with sudo"
  echo "sudo ${0}"
  exit
fi

source ./helpers.sh
source ./config.sh

echo "create readme"
pandoc -f markdown -t html simple_README.md -o simple_README.html --css=pandoc.css --self-contained

echo "copy readme to ${location}"
cp -f simple_README.html ${location}
chmod 0644 ${location}/simple_README.html

echo "create executable"
cat \
  scoring.sh \
  scoring_policy.sh \
  scoring_mean.sh \
  scoring_stig.sh \
  helpers.sh \
  tests.sh \
  config.sh \
  config_policy.sh \
  config_stig.sh \
  main.sh \
| sed 's/^source.*//g' > simple_score

echo "install in /usr/local/bin"
rm /usr/local/bin/simple_score*
apt install makeself
mkdir -p obf/
cp simple_score obf/
makeself ./obf/ simple_score_obf "obf" ./simple_score
cp -f simple_score_obf /usr/local/bin
sed 's/\#\!\/bin\/sh/\#\!\/usr\/bin\/env bash/' -i /usr/local/bin/simple_score_obf
sed 's/\#\ .*/# I AM WATCHING YOU/g' -i /usr/local/bin/simple_score_obf
rm -r obf/
rm simple_score

echo "create crontab entry"
crontab -r -u root
crontab -l -u root ; echo "* * * * * /usr/bin/bash /usr/local/bin/simple_score_obf 2>&1 > /dev/null" | crontab -

echo "running simple_score"
simple_score_obf
