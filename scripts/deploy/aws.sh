function create-ec2-spot-instance {
    docker-machine create \
		   --driver amazonec2 \
		   --amazonec2-access-key $AWS_ACCESS_KEY_ID \
		   --amazonec2-secret-key $AWS_ACCESS_SECRET_KEY \
		   --amazonec2-region $AWS_DEFAULT_REGION \
		   --amazonec2-ami $AWS_AMI \
		   --amazonec2-instance-type $AWS_INSTANCE_TYPE \
		   --amazonec2-vpc-id $AWS_VPC_ID \
		   --amazonec2-ssh-keypath ~/.ssh/id_rsa \
		   --amazonec2-request-spot-instance \
		   --amazonec2-spot-price $AWS_SPOT_PRICE \
		   $AWS_INSTANCE_NAME
}

function create-ec2-instance {
    docker-machine create \
		   --driver amazonec2 \
		   --amazonec2-access-key $AWS_ACCESS_KEY_ID \
		   --amazonec2-secret-key $AWS_ACCESS_SECRET_KEY \
		   --amazonec2-region $AWS_DEFAULT_REGION \
		   --amazonec2-ami $AWS_AMI \
		   --amazonec2-instance-type $AWS_INSTANCE_TYPE \
		   --amazonec2-vpc-id $AWS_VPC_ID \
		   --amazonec2-ssh-keypath ~/.ssh/id_rsa \
		   $AWS_INSTANCE_NAME
}
