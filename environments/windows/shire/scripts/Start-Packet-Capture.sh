#!/bin/bash

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

usage(){
    echo " "
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -r     Resource Group Name"
    echo "   -s     Storage Account Name"
    echo "   -c     Computer Names (e.g VM01,VM02)"
    echo
    echo "Examples:"
    echo " $0 -r resourcegroup01 -s storageaccount01 -c VM01,VM02"
    echo " "
    exit 1
}

# ************ Command Options **********************
while getopts r:s:c:h option
do
    case "${option}"
    in
        r) RESOURCE_GROUP=$OPTARG;;
        s) STORAGE_ACCOUNT=$OPTARG;;
        c) COMPUTER_NAMES=$OPTARG;;
        h) usage;;
    esac
done

if ((OPTIND == 1))
then
    echo "No options specified"
    usage
fi

if [ -z "$RESOURCE_GROUP" ] || [ -z "$STORAGE_ACCOUNT" ] || [ -z "$COMPUTER_NAMES" ]; then
  echo "[!] Make sure you provide values for the Resource group (-r), Storage Account (-s) and Computer Names (-c) parameters."
  usage
else
    IFS=', ' read -r -a COMPUTER_ARRAY <<< "$COMPUTER_NAMES"
    for COMPUTER in "${COMPUTER_ARRAY[@]}"; do
        sleep 5
        echo "[+] Starting ${COMPUTER}_PCAP session.."
        az network watcher packet-capture create --resource-group ${RESOURCE_GROUP} --vm ${COMPUTER} --name "${COMPUTER}_PCAP" --storage-account ${STORAGE_ACCOUNT} --filters "
    [
        {
            \"localIPAddress\":\"10.0.0.0-10.0.1.9\",
            \"remoteIPAddress\":\"10.0.0.0-10.0.1.9\"
        },
        {
            \"localIPAddress\":\"10.0.0.0-10.0.1.9\",
            \"remoteIPAddress\":\"192.168.0.0-192.168.0.10\"
        }
    ]
    "
    done
fi
