#!/usr/bin/env bash

source ./helpers.sh
source ./config.sh

#csv="foo,bar,baz,eep"

#IFS=,;read line <<<$csv && fields=( $line ) 
#declare -p fields

declare -A somehash=(
  [list]="val1,
          val2,
          val3,
          val4"
)

echo "${somehash[list]}" | tr -s " "

#configure_users
