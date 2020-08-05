#!/bin/bash

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

usage(){
    echo " "
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -n         EventHub Namespace"
    echo "   -c         EventHub Connection String Primary"
    echo "   -e         EventHub name"
    echo "   -u         Local user to update files ownership"
    echo
    echo "Examples:"
    echo " $0 -n <eventhubNamespace> -c <Endpoint=sb://xxxxx> -e <event hub name> -u wardog"
    echo " "
    exit 1
}

# ************ Command Options **********************
while getopts :n:c:e:u:h option
do
    case "${option}"
    in
        n) EVENTHUB_NAMESPACE=$OPTARG;;
        c) EVENTHUB_CONNECTIONSTRING=$OPTARG;;
        e) EVENTHUB_NAME=$OPTARG;;
        u) LOCAL_USER=$OPTARG;;
        h) usage;;
    esac
done

if ((OPTIND == 1))
then
    echo "No options specified"
    usage
fi

if [ -z "$EVENTHUB_NAMESPACE" ] || [ -z "$EVENTHUB_CONNECTIONSTRING" ] || [ -z "$EVENTHUB_NAME" ] || [ -z "$LOCAL_USER" ]; then
  usage
else
    # Install Docker and Docker-Compose
    ./Install-Docker.sh

    echo "creating local logstash folders"
    mkdir -p /opt/logstash/scripts
    mkdir -p /opt/logstash/pipeline
    mkdir -p /opt/logstash/config

    echo "Downloading logstash files locally to be mounted to docker container"
    wget -O /opt/logstash/scripts/logstash-entrypoint.sh https://raw.githubusercontent.com/OTRF/mordor-labs/master/environments/windows/shire/logstash/scripts/logstash-entrypoint.sh
    wget -O /opt/logstash/pipeline/eventhub.conf https://raw.githubusercontent.com/OTRF/mordor-labs/master/environments/windows/shire/logstash/pipeline/eventhub.conf
    wget -O /opt/logstash/config/logstash.yml https://raw.githubusercontent.com/OTRF/mordor-labs/master/environments/windows/shire/logstash/config/logstash.yml
    wget -O /opt/logstash/docker-compose.yml https://raw.githubusercontent.com/OTRF/mordor-labs/master/environments/windows/shire/logstash/docker-compose.yml
    wget -O /opt/logstash/Dockerfile https://raw.githubusercontent.com/OTRF/mordor-labs/master/environments/windows/shire/logstash/Dockerfile

    chown -R $LOCAL_USER:$LOCAL_USER /opt/logstash/*
    chmod +x /opt/logstash/scripts/logstash-entrypoint.sh

    export BOOTSTRAP_SERVERS=$EVENTHUB_NAMESPACE.servicebus.windows.net:9093
    export SASL_JAAS_CONFIG="org.apache.kafka.common.security.plain.PlainLoginModule required username=\$ConnectionString password='$EVENTHUB_CONNECTIONSTRING';"
    export EVENTHUB_NAME=$EVENTHUB_NAME

    cd /opt/logstash/ && docker-compose -f docker-compose.yml up --build -d
fi