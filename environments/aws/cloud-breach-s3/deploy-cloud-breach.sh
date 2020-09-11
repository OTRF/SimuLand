#!/bin/bash
set -e

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

usage(){
    echo " "
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -r             set region"
    echo "   -h             Prints this message"
    echo
    echo "Examples:"
    echo " $0 -r 'us-east-1'    Deploy stacks in the us-east-1 region"
    echo " "
    exit 1
}

# ************ Command Options **********************
MORDOR_REGION="us-east-1"
while getopts r:h option
do
    case "${option}"
    in
        r) MORDOR_REGION=$OPTARG;;
        h | [?]) usage ; exit;;
    esac
done

echo " "
echo "=========================="
echo "* Deploying Cloud Breach *"
echo "=========================="
echo " "
echo " "
aws --region $MORDOR_REGION cloudformation create-stack --stack-name MordorS3Stack --template-body file://./cfn-templates/s3.json
echo " "
echo " WAITING FOR S3..."
echo " "
aws --region $MORDOR_REGION cloudformation wait stack-create-complete --stack-name MordorS3Stack
echo " "
echo "RUNNING ENABLE CLOUD TRAIL"
echo " "
aws --region $MORDOR_REGION cloudformation create-stack --stack-name MordorCTStack --template-body file://./cfn-templates/enable-cloudtrail.json
echo " "
echo "RUNNING VPC"
aws --region $MORDOR_REGION cloudformation create-stack --stack-name MordorVPCStack --template-body file://./cfn-templates/vpc.json --parameters file://./cfn-parameters/vpc-parameters.json
echo " "
echo "WAITING FOR VPC..."
echo " "
aws --region $MORDOR_REGION cloudformation wait stack-create-complete --stack-name MordorVPCStack
echo "RUNNING EC2..."
echo " "
aws --region $MORDOR_REGION cloudformation create-stack --stack-name MordorEC2Stack --template-body file://./cfn-templates/ec2.json --parameters file://./cfn-parameters/ec2-parameters.json --capabilities CAPABILITY_NAMED_IAM