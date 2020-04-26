# APT29 Evals Emulation Setup

This Mordor environment was built to replicate a similar setup developed by the ATT&CK Evals team following their official [emulation plan methodology](https://github.com/mitre-attack/attack-arsenal/blob/master/adversary_emulation/APT29/Emulation_Plan/APT29_EmuPlan.pdf) and using several of the [PowerShell scripts](https://github.com/mitre-attack/attack-arsenal/tree/master/adversary_emulation/APT29/Emulation_Plan) used for the main evaluation. The main goal of this environment is to share the free telemetry produced after executing the APT29 emulation plan scenarios and create detection research opportunities for the Infosec community.

## Full Environment Documentation

### https://blacksmith.readthedocs.io/en/latest/mordor_labs.html

# Quick Deployment

## Point-To-Site VPN Certificates Setup

## Create a root CA Certificate

Step-by-Step: https://blacksmith.readthedocs.io/en/latest/azure_p2s_vpn_setup.html#create-a-root-ca-certificate

After getting a root CA Certificate

* Get the name of it
* Get the root CA cert data by running the following commands:

```
openssl x509 -in caCert.pem -outform def | base64 | pbcopy
```

## Deploy Environment

Clone the project and change your directory to the apt29 one

```
https://github.com/OTRF/mordor-labs
cd mordor-labs/tree/master/environments/attack-evals/apt29
```

### Azure CLI Setup

Install and set up Azure CLI

https://blacksmith.readthedocs.io/en/latest/azure_cli_setup.html

Create an Azure Resource group

```
az group create --location eastus --resource-group MyResourceGroup
```

### Create Deployment

Use the following commands to create the environment

### Day 1

```
az group deployment create --name <Deployment Name> --resource-group <Resource Group Name> --template-file azuredeploy.json --parameters adminUsername=wardog adminPassword='TuT3rr0r!12345' pickScenario="Day1" setDataPipeline=WEF-LOGSTASH-EVENTHUB clientRootCertName=<Root CA Certificate Name> clientRootCertData="<Root CA Cert Data>"
```

### OpenVPN Client Setup

Reference: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-openvpn-clients