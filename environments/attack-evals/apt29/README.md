# APT29 Evals Emulation Setup

This Mordor environment was built to replicate a similar setup developed by the ATT&CK Evals team following their official [emulation plan methodology](https://github.com/mitre-attack/attack-arsenal/blob/master/adversary_emulation/APT29/Emulation_Plan/APT29_EmuPlan.pdf) and using several of the [PowerShell scripts](https://github.com/mitre-attack/attack-arsenal/tree/master/adversary_emulation/APT29/Emulation_Plan) used for the main evaluation. The main goal of this environment is to share the free telemetry produced after executing the APT29 emulation plan scenarios and create detection research opportunities for the Infosec community.

Full documentation:

## Point-To-Site VPN Certificates Setup

**Create a root CA Certificate**

Step-by-Step: https://blacksmith.readthedocs.io/en/latest/azure_p2s_vpn_setup.html#create-a-root-ca-certificate

After getting a root CA Certificate

* Get the name of it (CN= Root CA Name)
* Get the root CA cert data by running the following commands and save it to pass it as a parameter while creating the environment.

```
openssl x509 -in caCert.pem -outform der | base64 | pbcopy
```

## Deploy Environment

Clone the project and change your directory to the apt29 one

```
https://github.com/OTRF/mordor-labs
cd mordor-labs/tree/master/environments/attack-evals/apt29
```

**Azure CLI Setup**

Install and set up Azure CLI

https://blacksmith.readthedocs.io/en/latest/azure_cli_setup.html

Create an Azure Resource group

```
az group create --location eastus --resource-group MyResourceGroup
```

**Create Deployment**

Use the following commands to create the environment

Day 1

```
az group deployment create --name <Deployment Name> --resource-group <Resource Group Name> --template-file azuredeploy.json --parameters adminUsername=<USERNAME> adminPassword='<PASSWORD>' pickScenario="Day1" setDataPipeline=WEF-LOGSTASH-EVENTHUB clientRootCertName=<Root CA Certificate Name> clientRootCertData="<Root CA Cert Data>"
```

## Connect to Azure Network environment (P2S VPN)

VMs deployed in Azure will not be accessible via their Public IP addresses. A Point-To-Site (P2S) VPN is set up and you will need to use a client certificate signed with the CA's root private key created earlier. 

**Create a client Certificate signed with the CA’s root key**

Step-by-Step: https://blacksmith.readthedocs.io/en/latest/azure_p2s_vpn_setup.html#create-a-client-certificate-signed-with-the-ca-s-root-key

**OpenVPN Client Setup**

Step-by-Step: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-howto-openvpn-clients

* Use the Client's Certificate (PEM format)
* Use the Client's Private Key (PEM format)

You will be ready to RDP or SSH to the Windows and Linux endpoints in the environment.

## Collect Security Event Logs

This environment comes with a data pipeline option to collect security event logs from Windows Endpoints via Windows Event Forwarding (WEF) configurations, send them to a Logstash pipeline which sends them over to an Azure Event Hub. From there, one could use tools such as Kafkacat to connect to the Azure Event hub, consume events being sent over and write them to a local JSON file in real-time.

**Install Kafkacat**

On recent enough Debian systems:

```
apt-get install kafkacat
```

And on Mac OS X with homebrew installed:

```
brew install kafkacat
```

**Kafkacat Conf File Setup**

Make sure you update the [**Kafkacat.conf**](kafkacat/kafkacat.conf) with the values from your environment.

**Run Kafkacat and Consume Events**

Once you create the environment, you can run the following command to start consuming events from the Azure Event Hub and write them to a local JSON file:

```
kafkacat -b <eventhub-namespace>.servicebus.windows.net:9093 -t <eventhunb-name> -F kafkacat.conf -C -o end > apt29_evals_$(date +%F%H%M%S).json
```

I would run that command right before starting to run every single step in the Apt29 Emulation plans.

## Execute Emulation Plan

* Blog Post:
* APT29 Scenarios:
    * Day 1
    * Day 2