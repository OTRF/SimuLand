#!/bin/bash
set -e

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

usage(){
    echo " "
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -r             set region"
    echo "   -p             set account profile"
    echo "   -h             Prints this message"
    echo
    echo "Examples:"
    echo " $0 -r 'us-east-1' -p stevie      Deploy stacks in the us-east-1 region with a specific profile"
    echo " "
    exit 1
}

# ************ Command Options **********************
MORDOR_REGION="us-east-1"
USER_PROFILE="default"
while getopts r:p:h option
do
    case "${option}"
    in
        r) MORDOR_REGION=$OPTARG;;
        p) USER_PROFILE=$OPTARG;;
        h | [?]) usage ; exit;;
    esac
done

echo " "
echo "=========================="
echo "* Deploying Cloud Breach *"
echo "=========================="
echo " "
if ! aws --region $MORDOR_REGION --profile $USER_PROFILE cloudformation describe-stacks --stack-name MordorS3Stack > /dev/null 2>&1; then
    echo "[+] Deploying vulnerable MordorS3Stack"
    aws --region $MORDOR_REGION --profile $USER_PROFILE cloudformation create-stack --stack-name MordorS3Stack --template-body file://./cfn-templates/s3.json
    echo "  [*] Waiting for MordorS3Stack creation"
    aws --region $MORDOR_REGION --profile $USER_PROFILE cloudformation wait stack-create-complete --stack-name MordorS3Stack
    echo "  [*] Copying local files to new S3 bucket"
    S3Bucket=$( echo $(aws cloudformation describe-stacks --stack-name MordorS3Stack --query "Stacks[0].Outputs[0].OutputValue") | tr -d '"')
    aws s3 cp data/ring.txt s3://$S3Bucket/
else
    echo "[+] MordorS3Stack already exists"
fi
echo " "
if ! aws --region $MORDOR_REGION --profile $USER_PROFILE cloudformation describe-stacks --stack-name MordorCTStack > /dev/null 2>&1; then
    echo "[+] Deploying MordorCTStack to enable CloudTrail logs"
    aws --region $MORDOR_REGION --profile $USER_PROFILE cloudformation create-stack --stack-name MordorCTStack --template-body file://./cfn-templates/enable-cloudtrail.json
else
    echo "[+] MordorS3Stack already exists"
fi
echo " "
if ! aws --region $MORDOR_REGION --profile $USER_PROFILE cloudformation describe-stacks --stack-name MordorVPCStack > /dev/null 2>&1; then
    echo "[+] Deploying MordorVPCStack"
    aws --region $MORDOR_REGION --profile $USER_PROFILE cloudformation create-stack --stack-name MordorVPCStack --template-body file://./cfn-templates/vpc.json --parameters file://./cfn-parameters/vpc-parameters.json
    echo "  [*] Waiting for MordorVPCStack creation"
    aws --region $MORDOR_REGION --profile $USER_PROFILE cloudformation wait stack-create-complete --stack-name MordorVPCStack
else
    echo "[+] MordorVPCStack already exists"
fi
echo " "
if ! aws --region $MORDOR_REGION --profile $USER_PROFILE cloudformation describe-stacks --stack-name MordorNginxStack > /dev/null 2>&1; then
    echo "[+] Deploying MordorNginxStack"
    aws --region $MORDOR_REGION --profile $USER_PROFILE cloudformation create-stack --stack-name MordorNginxStack --template-body file://./cfn-templates/ec2-nginx.json --parameters file://./cfn-parameters/ec2-nginx-parameters.json --capabilities CAPABILITY_NAMED_IAM
else
    echo "[+] MordorNginxStack already exists"
fi
echo " "
if ! aws --region $MORDOR_REGION --profile $USER_PROFILE cloudformation describe-stacks --stack-name MordorLogCollectorStack > /dev/null 2>&1; then
    echo "[+] Deploying MordorLogCollectorStack"
    echo "  [*] Waiting for CloudTrail stack creation"
    aws --region $MORDOR_REGION --profile $USER_PROFILE cloudformation wait stack-create-complete --stack-name MordorCTStack
    aws --region $MORDOR_REGION --profile $USER_PROFILE cloudformation create-stack --stack-name MordorLogCollectorStack --template-body file://./cfn-templates/ec2-log-collector.json --parameters file://./cfn-parameters/ec2-log-collector-parameters.json --capabilities CAPABILITY_NAMED_IAM
else
    echo "[+] MordorLogCollectorStack already exists"
fi
