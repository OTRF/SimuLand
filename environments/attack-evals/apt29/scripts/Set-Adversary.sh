#!/bin/bash

# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPL-3.0

# *********** Help ***************
usage(){
    echo " "
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -s         ATT&CK Eval APT29 scenario (e.g. Day1 or Day2)"
    echo "   -p         Switch to use Mitre Caldera DIY plugin"
    echo "   -h         help menu"
    echo
    echo "Examples:"
    echo " $0 -s Day1"
    echo " $0 -s Day1 -p"
    exit 1
}

# ************ Command Options **********************
while getopts s:ph option
do
    case "${option}"
    in
        s) SCENARIO=$OPTARG;;
        p) DIY_PLUGIN="True";;
        h) usage;;
    esac
done

if ((OPTIND == 1))
then
    echo "No options specified"
    usage
fi

if [ -z "$SCENARIO" ]; then
  usage
else
    # Install Docker and Docker-Compose
    ./Install-Docker.sh

    # *********** Validating Input ***************
    case $SCENARIO in
        Day1);;
        Day2);;
        *)
            echo "$ERROR_TAG Not a valid scenario option. Valid Options: Day1 or Day2"
            usage
        ;;
    esac

    if [[ $DIY_PLUGIN ]]; then
        mkdir -p /opt/caldera/conf
        mkdir -p /opt/caldera/data/abilities/host-provision
        
        # Add Custom Facts
        mv 4fb34bde-b06d-445a-a146-8e35f79ce546.yml /opt/caldera/conf/4fb34bde-b06d-445a-a146-8e35f79ce546.yml
        
        # Download Fix (Step 11)
        wget -O /opt/caldera/data/abilities/host-provision/865b6ad9-ba59-435a-bd8f-641052fc077a.yml https://raw.githubusercontent.com/OTRF/mordor-labs/master/environments/attack-evals/apt29/caldera/data/abilities/host-provision/865b6ad9-ba59-435a-bd8f-641052fc077a.yml
        chmod -R 755 /opt/caldera

        # ********* Build *************
        docker image pull cyb3rward0g/docker-caldera:evals-042720
        docker tag cyb3rward0g/docker-caldera:evals-042720 docker-caldera
        
        # ********* Run *************
        docker run --rm -it -p 8888:8888 -p 7010:7010 -p 7011:7011/udp -p 7012:7012 -v /opt/caldera/conf/4fb34bde-b06d-445a-a146-8e35f79ce546.yml:/usr/src/app/plugins/evals/data/sources/4fb34bde-b06d-445a-a146-8e35f79ce546.yml -v /opt/caldera/data/abilities/host-provision/865b6ad9-ba59-435a-bd8f-641052fc077a.yml:/usr/src/app/plugins/evals/data/abilities/host-provision/865b6ad9-ba59-435a-bd8f-641052fc077a.yml --name caldera -d docker-caldera

    else
        apt update -y
        apt install -y git unzip

        # Decompress attacker payloads
        unzip attack-platform.zip -d /opt/

        # *********** Running default C2 Selected ***********
        if [[ $SCENARIO == "Day1" ]]; then
            # *********** Update Payload Rights **************
            chmod -R 755 /opt/attack-platform/
            mkdir -p /srv/dav/data
            cp /opt/attack-platform/Seaduke/python.exe /srv/dav/data/
            chmod -R 755 /srv/dav/data

            # *********** WebDav Docker *****************
            # Reference: https://docs.bytemark.co.uk/article/run-your-own-webdav-server-with-docker/
            docker run --restart always -v /srv/dav:/var/lib/dav -e AUTH_TYPE=Digest -e USERNAME=cozy -e PASSWORD=MyCozyPassw0rd! --publish 80:80 --name webdav -e LOCATION=/webdav -d bytemark/webdav

            # *********** Pupy Docker ***************    
            docker image pull cyb3rward0g/docker-pupy:f8c829dd66449888ec3f4c7d086e607060bca892
            docker tag cyb3rward0g/docker-pupy:f8c829dd66449888ec3f4c7d086e607060bca892 docker-pupy 
            
            # Run manually:
            # docker run --rm -it -p 1234:1234 -v "/opt/attack-platform:/tmp/attack-platform" docker-pupy python pupysh.py

            # *********** Metasploit Docker *************** 
            docker image pull metasploitframework/metasploit-framework

            # Run manually:
            # docker run --rm -it -p 443:443 -v "/opt/attack-platform:/tmp/attack-platform" metasploitframework/metasploit-framework ./msfconsole
            # docker run --rm -it -p 8443:8443 -v "/opt/attack-platform:/tmp/attack-platform" metasploitframework/metasploit-framework ./msfconsole

        else
            # create project folder
            mkdir /opt/PoshC2_Project
            # Install PoshC2
            curl -sSL https://raw.githubusercontent.com/nettitude/PoshC2/master/Install-for-Docker.sh | bash
            # Pull docker image
            docker image pull cyb3rward0g/docker-poshc2:20200417
            # tag image to be compatible with official PoshC2 scripts
            docker tag cyb3rward0g/docker-poshc2:20200417 poshc2

            # Copy Day2 scripts to PoshC2 Modules
            mv /opt/attack-platform/m /tmp/
            cp /opt/attack-platform/* /opt/PoshC2/resources/modules/

            # Run Server Manually to create a few One-Liners!
            # sudo docker run -ti --rm -p 443:443 -v /opt/PoshC2_Project:/opt/PoshC2_Project -v /opt/PoshC2:/opt/PoshC2 -e PAYLOAD_COMMS_HOST=https://192.168.0.4 poshc2 /usr/bin/posh-server

            # Make sure you update the scripts following ATT&CK evals Red Team Setup steps for day 2 in the /opt/PoshC2/resources/modules/ folder. 
            # https://github.com/mitre-attack/attack-arsenal/tree/master/adversary_emulation/APT29/Emulation_Plan/Day%202#red-team-setup

            # Run Client Manually
            # sudo docker run -ti --rm -v /opt/PoshC2_Project:/opt/PoshC2_Project -v /opt/PoshC2:/opt/PoshC2 poshc2 /usr/bin/posh
        fi
    fi
fi