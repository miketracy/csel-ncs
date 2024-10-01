#!/usr/bin/env bash

uid=`id -g`
if [ "$uid" != "0" ]; then
  echo "run script with sudo"
  echo "sudo ${0}"
  exit
fi

declare -a __list

source ./helpers.sh
source ./config.sh

echo "create readme"
pandoc -f markdown -t html simple_README.md -o simple_README.html --css=pandoc.css --self-contained

echo "copy readme to ${location}"
cp -f simple_README.html ${location}
chmod 0644 ${location}/simple_README.html

echo "install forensics questions"
declare -n list="${forensics_questions[questions]}"
for file in "${list[@]}"; do
  cp -f ./forensics/$file $location
  chown ${cpuser}:${cpuser} ${location}/${file}
  chmod 0644 ${location}/${file}
done

echo "create executable"
cat \
  scoring.sh \
  scoring_policy.sh \
  helpers.sh \
  config.sh \
  config_policy.sh \
  config_stig.sh \
  main.sh \
| sed 's/^source.*//g' > simple_score

echo "install in /usr/local/bin"
cp -f simple_score /usr/local/bin

echo "create crontab entry"
if [[ $(crontab -l -u root | grep simple) ]]; then
  # do nothing
  :
else
  (crontab -l -u root ; echo "* * * * * /bin/bash /usr/local/bin/simple_score")| crontab -
fi

echo "running simple_score"
simple_score
