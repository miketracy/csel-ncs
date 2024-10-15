# TODO

debug_check_stig () {
  [[ $debug -lt 2 ]] && return 1
  declare -n struct=stig_checks
  for key in ${!struct[@]}; do
    if [[ "$key" != "points" ]]; then
      declare -n list="${struct[$key]}"
      debug "testing: $key"
      for val in "${list[@]}"; do
        debug "${key} has ${val}"
      done
    fi
  done
}
