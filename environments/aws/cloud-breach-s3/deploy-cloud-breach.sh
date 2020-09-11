#!/bin/bash
set -e

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

echo " "
echo "=========================="
echo "* Deploying Cloud Breach *"
echo "=========================="
echo " "
echo " "
aws --region us-east-1 cloudformation create-stack --stack-name MordorS3Stack--template-body file://./cfn-templates/s3.json
echo " "
echo " WAITING FOR S3..."
echo " "
aws --region us-east-1 cloudformation wait stack-create-complete --stack-name MordorS3Stack
echo " "
echo "RUNNING ENABLE CLOUD TRAIL"
echo " "
aws --region us-east-1 cloudformation create-stack --stack-name MordorCTStack --template-body file://./cfn-templates/enable-cloudtrail.json
echo " "
echo "RUNNING VPC"
aws --region us-east-1 cloudformation create-stack --stack-name MordorVPCStack --template-body file://./cfn-templates/vpc.json --parameters file://./cfn-parameters/vpc-parameters.json
echo " "
echo "WAITING FOR VPC..."
echo " "
aws --region us-east-1 cloudformation wait stack-create-complete --stack-name MordorVPCStack
echo "RUNNING EC2..."
echo " "
aws --region us-east-1 cloudformation create-stack --stack-name MordorEC2Stack --template-body file://./cfn-templates/ec2.json --parameters file://./cfn-parameters/ec2-parameters.json