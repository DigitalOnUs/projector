check_params(){
  for param in $required_params; do
    if [ -z "${!param}" ]; then
      echo
      echo "ERROR: parameter $param is not set."
      declare -f usage >/dev/null && usage
      exit 1
    fi
  done
}
