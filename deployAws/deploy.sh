#!/bin/bash

CMD=`basename $0`
required_params='AWS_ACCESS_KEY_ID AWS_ACCESS_SECRET_KEY AWS_DEFAULT_REGION AWS_AMI AWS_INSTANCE_TYPE AWS_VPC_ID AWS_SPOT_PRICE AWS_INSTANCE_NAME ADOP_DIR ADOP_USER ADOP_PWD ADOP_COMMIT'

source params.sh
source check-params.sh

usage(){
  cat <<EOF
Usage: $CMD [options] <AWS_INSTANCE_NAME>
  Deploy ADOP into AWS spot instance with given name.
Environment variables:
  Set the following environment variables in file params.sh.
  AWS_ACCESS_KEY_ID           Your access key ID (REQUIRED)
  AWS_ACCESS_SECRET_KEY       Your access key (REQUIRED)
  AWS_DEFAULT_REGION          AWS region for your instance
  AWS_AMI                     AWS AMI for your instance
  AWS_INSTANCE_TYPE           AWS instance type
  AWS_VPC_ID                  AWS VPC
  AWS_SPOT_PRICE              Spot price
  ADOP_DIR                    Directory where ADOP will be cloned
  ADOP_USER                   User for your ADOP system
  ADOP_PWD                    Password for your user
  ADOP_COMMIT                 Commit that will be deployed to instance
Options:
  The following options override corresponding environment variables.
  -t <instance type>          AWS instance type as specified in
                              https://aws.amazon.com/ec2/instance-types/
  -n <vpc id>                 AWS VPC ID, e.g. vpc-5a1dfb4c
  -p <spot price>             Spot price for instance, e.g. 0.2
  -s                          Skip creation of AWS intance
  -h                          Print usage and exit
EOF
}

while getopts "t:n:p:sh" OPT; do
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
AWS_INSTANCE_NAME=${@: -1}

check_params

echo export AWS_INSTANCE_NAME=$AWS_INSTANCE_NAME >instance-name.sh

if [ -z "$SKIP_CREATE_INSTANCE" ]; then
  echo "Creating EC2 instance $AWS_INSTANCE_NAME"
  if ! docker-machine create \
    --driver amazonec2 \
    --amazonec2-access-key $AWS_ACCESS_KEY_ID \
    --amazonec2-secret-key $AWS_ACCESS_SECRET_KEY \
    --amazonec2-region $AWS_DEFAULT_REGION \
    --amazonec2-ami $AWS_AMI \
    --amazonec2-instance-type $AWS_INSTANCE_TYPE \
    --amazonec2-vpc-id $AWS_VPC_ID \
    --amazonec2-ssh-keypath ~/.ssh/id_rsa \
    $AWS_INSTANCE_NAME; then
    echo
    echo "ERROR: Could not create EC2 instance $AWS_INSTANCE_NAME"
    exit 1
  fi
fi

docker-machine env $AWS_INSTANCE_NAME

eval $(docker-machine env $AWS_INSTANCE_NAME)

#if [ ! -a $ADOP_DIR ]; then
  echo 'Clonning ADOP repo'
  mkdir -p $ADOP_DIR
#  git clone https://github.com/Accenture/adop-docker-compose.git $ADOP_DIR
  git clone -b 2-deploy-to-aws https://github.com/DigitalOnUs/projector.git $ADOP_DIR
  cd $ADOP_DIR
  ls -lrth $ADOP_DIR
#elif [ ! -d $ADOP_DIR ]; then
#  echo
#  echo "ERROR: ADOP dir $ADOP_DIR exists and is not a directory."
#  exit 1
#fi

#echo "Checking out ADOP commit $ADOP_COMMIT"
##if ! cd $ADOP_DIR && git checkout $ADOP_COMMIT; then
#if ! cd $ADOP_DIR; then
#  echo
#  echo "ERROR: could not checkout commit $ADOP_COMMIT."
#  exit 1
#fi

echo "Deploying ADOP in $AWS_INSTANCE_NAME"
#./quickstart.sh -t aws -c $AWS_VPC_ID -r $AWS_DEFAULT_REGION -u $ADOP_USER -p $ADOP_PWD -m $AWS_INSTANCE_NAME
cd $ADOP_DIR
./start.sh
