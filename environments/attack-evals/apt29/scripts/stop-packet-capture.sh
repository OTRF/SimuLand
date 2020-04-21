#!/bin/bash

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

usage(){
    echo " "
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -r     Resource Group Name"
    echo "   -c     Computer Names (e.g 'VICTIM01' 'VICTIM02')"
    echo "   -l     Location (e.g eastus)"
    echo "   -d     Delete PCAP session (Optional)"
    echo
    echo "Examples:"
    echo " $0 -r rgn -c 'VICTIM01' 'VICTIM02' -l eastus"
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
  usage
else
    for COMPUTER in "${COMPUTER_NAMES}"; do
        echo "[+] Stopping ${COMPUTER}_PCAP session"
        az network watcher packet-capture stop --name "${COMPUTER}_PCAP" --location ${LOCATION}
        if [ ${DELETE_PCAP_SESSION} ]; then
            echo "[+] Deleting ${COMPUTER}_PCAP session"
            az network watcher packet-capture delete --name "${COMPUTER}_PCAP" --location ${LOCATION}
        fi
    done
fi
