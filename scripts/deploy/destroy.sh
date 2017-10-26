#!/bin/bash

CMD=`basename $0`
CMD_DIR=`dirname $0`
REPO_ROOT=`dirname $0`/../../
required_params='AWS_INSTANCE_NAME'

source $CMD_DIR/params.sh
source $CMD_DIR/check-params.sh
[ -e $REPO_ROOT/.aws-instance-name ] && export AWS_INSTANCE_NAME=`cat $REPO_ROOT/.aws-instance-name`

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
