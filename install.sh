#!/usr/bin/env bash

uid=`id -g`
if [ "$uid" != "0" ]; then
  echo "run script with sudo"
  echo "sudo ${0}"
  exit
fi

source ./helpers.sh
source ./config.sh

echo "create executable"
cat helpers.sh config.sh scoring.sh | sed 's/^source.*//g' > simple_score

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
