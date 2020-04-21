#!/bin/bash

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

usage(){
    echo " "
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -i     Target IP Address to redirect traffic to"
    echo "   -h         help menu"
    echo
    echo "Examples:"
    echo " $0 -i 192.168.0.4"
    exit 1
}

# ************ Command Options **********************
while getopts i:h option
do
    case "${option}"
    in
        i) TARGET_IP=$OPTARG;;
        h) usage;;
    esac
done

if ((OPTIND == 1))
then
    echo "No options specified"
    usage
fi

if [ -z "$TARGET_IP" ]; then
  usage
else
    #Install dependencies
    apt update -y
    apt install -y socat

    # Set up Socat
    socat TCP-LISTEN:443,fork TCP:${TARGET_IP}:443 &
    socat TCP-LISTEN:1234,fork TCP:${TARGET_IP}:1234 &
    socat TCP-LISTEN:8443,fork TCP:${TARGET_IP}:8443 &
fi