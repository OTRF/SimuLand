#!/bin/bash

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

usage(){
    echo " "
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -r     Resource Group Name"
    echo "   -c     Computer Names (e.g VM01,VM02)"
    echo "   -l     Location (e.g eastus)"
    echo "   -d     Delete PCAP session (Optional)"
    echo
    echo "Examples:"
    echo " $0 -r resourcegroup01 -c VM01,VM02 -l eastus"
    echo " "
    exit 1
}

# ************ Command Options **********************
while getopts r:c:l:dh option
do
    case "${option}"
    in
        r) RESOURCE_GROUP=$OPTARG;;
        c) COMPUTER_NAMES=$OPTARG;;
        l) LOCATION=$OPTARG;;
        d) DELETE_PCAP_SESSION="TRUE";;
        h) usage;;
    esac
done

if ((OPTIND == 1))
then
    echo "No options specified"
    usage
fi

if [ -z "$RESOURCE_GROUP" ] || [ -z "$COMPUTER_NAMES" ] || [ -z "$LOCATION" ]; then
  echo "[!] Make sure you provide values for the Resource group (-r), Computer Names (-c) parameters and Location (-l)."
  usage
else
    IFS=', ' read -r -a COMPUTER_ARRAY <<< "$COMPUTER_NAMES"
    for COMPUTER in "${COMPUTER_ARRAY[@]}"; do
        sleep 5
        echo "[+] Stopping ${COMPUTER}_PCAP session"
        az network watcher packet-capture stop --name "${COMPUTER}_PCAP" --location ${LOCATION}
        if [ ${DELETE_PCAP_SESSION} ]; then
            echo "[+] Deleting ${COMPUTER}_PCAP session"
            az network watcher packet-capture delete --name "${COMPUTER}_PCAP" --location ${LOCATION}
        fi
    done
fi
