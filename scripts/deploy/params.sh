export AWS_ACCESS_KEY_ID=`cat $REPO_ROOT/.aws-access-key`
export AWS_ACCESS_SECRET_KEY=`cat $REPO_ROOT/.aws-secret-key`
export AWS_INSTANCE_NAME=${AWS_INSTANCE_NAME:-projector}
export AWS_DEFAULT_REGION=us-east-1
export AWS_AMI=ami-841f46ff
export AWS_INSTANCE_TYPE=m4.2xlarge
export AWS_VPC_ID=vpc-62996e04
export AWS_USE_SPOT=1
export AWS_SPOT_PRICE=0.2
export ADMIN_PWD=${ADMIN_PWD:-projectoradmin}
