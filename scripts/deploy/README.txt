Deploy Projector on AWS

1.- Create EC2 instance.
      a) Create scripts for deploying instance in AWS and setting parameters.
      b) Set VPC ID in parameters.
      c) Define an AWS instance and run ./setup.sh <AWS instance name>
2.- Deploy app into the instance
      a) git clone under the instance
      b) docker-compose up
3.- Open ports.
4.- Make everything automatic.

NOTE: After deploying the AWS Spot Instance, show the IP adreess.
      Task 2:
              Log in to Spot Instance:
              Example: ssh -i "/Users/jpreza/.ssh/kube_aws_rsa" admin@35.164.34.226
