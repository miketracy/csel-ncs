#!/usr/bin/env bash

csv="foo,bar,baz,eep"

IFS=,;read line <<<$csv && fields=( $line ) 
declare -p fields
