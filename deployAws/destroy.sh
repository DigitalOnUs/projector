MD=`basename $0`
required_params='AWS_INSTANCE_NAME ADOP_DIR'

source params.sh
source check-params.sh
[ -e instance-name.sh ] && source instance-name.sh

usage(){
  cat <<EOF
Usage: $CMD [<AWS_INSTANCE_NAME>]
  Destroy AWS instance and reset corresponding ADOP repo.
  When no instance is specified, last AWS instance name given
  to ./deploy.sh is used.
EOF
}

AWS_INSTANCE_NAME=${AWS_INSTANCE_NAME:-${@: -1}}

check_params

echo "Removing instance $AWS_INSTANCE_NAME"
docker-machine rm --force $AWS_INSTANCE_NAME

if [ -d $ADOP_DIR ]; then
  echo "Cleaning ADOP repo $ADOP_DIR"
  cd $ADOP_DIR
  git clean -d -x -f
else
  echo "Skipping clean of ADOP repo $ADOP_DIR, directory does not exist"
fi
