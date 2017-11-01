#!/bin/bash

CMD=`basename $0`
CMD_DIR=`dirname $0`
REPO_ROOT=`dirname $0`/../../
required_params='AWS_ACCESS_KEY_ID AWS_ACCESS_SECRET_KEY AWS_INSTANCE_NAME AWS_DEFAULT_REGION AWS_AMI AWS_INSTANCE_TYPE AWS_VPC_ID AWS_USE_SPOT AWS_SPOT_PRICE ADMIN_PWD'

source $CMD_DIR/params.sh
source $CMD_DIR/check-params.sh
source $CMD_DIR/aws.sh

usage(){
  cat <<EOF
Usage: $CMD [options] <AWS_INSTANCE_NAME>
  Deploy Projector into AWS EC2 instance with given name.
Environment variables:
  Set the following environment variables in file params.sh.
  AWS_ACCESS_KEY_ID           Your access key ID (REQUIRED)
  AWS_ACCESS_SECRET_KEY       Your access key (REQUIRED)
  AWS_INSTANCE_NAME           Name for your instance
  AWS_DEFAULT_REGION          AWS region for your instance
  AWS_AMI                     AWS AMI for your instance
  AWS_INSTANCE_TYPE           AWS instance type
  AWS_VPC_ID                  AWS VPC
  AWS_USE_SPOT                Use a spot instance
  AWS_SPOT_PRICE              Spot price
  ADMIN_PWD                   Password for admin user
Options:
  The following options override corresponding environment variables.
  -t <instance type>          AWS instance type as specified in
                              https://aws.amazon.com/ec2/instance-types/
  -n <vpc id>                 AWS VPC ID, e.g. vpc-5a1dfb4c
  -p <spot price>             Spot price for instance, e.g. 0.2
  -s                          Skip creation of AWS intance
  -r                          Use a regular EC2 instance instead of a spot intance
  -h                          Print usage and exit
EOF
}

while getopts "t:n:p:srh" OPT; do
  case $OPT in
    t)
      AWS_INSTANCE_TYPE=$OPTARG
      ;;
    n)
      AWS_VPC_ID=$OPTARG
      ;;
    p)
      AWS_SPOT_PRICE=$OPTARG
      ;;
    s)
      SKIP_CREATE_INSTANCE=1
      ;;
    r)
      AWS_USE_SPOT=0
      ;;
    h)
      usage
      exit 0
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done
AWS_INSTANCE_NAME=${AWS_INSTANCE_NAME:-${@: -1}}

check_params

echo $AWS_INSTANCE_NAME >$REPO_ROOT/.aws-instance-name

if [ -z "$SKIP_CREATE_INSTANCE" ]; then
  if [ "$AWS_USE_SPOT" = 1 ]; then
      echo "Creating EC2 spot instance $AWS_INSTANCE_NAME"
      CREATE_CMD=create-ec2-spot-instance
  else
  echo "Creating EC2 instance $AWS_INSTANCE_NAME"
      CREATE_CMD=create-ec2-instance
  fi
  if ! $CREATE_CMD; then
    echo
    echo "ERROR: Could not create EC2 instance $AWS_INSTANCE_NAME"
    exit 1
  fi
fi

if ! docker-machine env $AWS_INSTANCE_NAME; then
    echo
    echo "ERROR: Cannot docker-machine to $AWS_INSTANCE_NAME"
    exit 1
fi

eval $(docker-machine env $AWS_INSTANCE_NAME)
export VIRTUAL_HOST=`echo $DOCKER_HOST | sed -e 's#tcp://##' -e 's/:[0-9]*//'`

echo "Deploying Projector in $AWS_INSTANCE_NAME"
$REPO_ROOT/scripts/control/start.sh -d
