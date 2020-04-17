# ATT&CK Evals - Mordor Environments

## Cloud Infrastructure

Mordor labs uses Azure Resource Manager (ARM) templates to define the infrastructure and configurations to deploy all the resources needed to replicate the environments used during the ATT&CK evals scenarios and collect telemetry generated after emulating adversaries.

### What are ARM Templates?

They are JavaScript Object Notation (JSON) files that allow you to define the infrastructure and configuration for your project in a declarative syntax. ARM templates leverage the deployment and management services for Azure which lets deploy Azure resources without having to write a sequence of programming commands to create it.

## Securing Resources

All the resources that cannot be disclosed to the public yet require restricted access configurations that we decided to take care of via [Azure storage accounts and private containers](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction). Our team collaborates through public GitHub repositories, and it is crucial to maintain a similar level of flexibility while developing ARM templates and scripts to deploy attack evals environments before their main release. Therefore, we move every resource that we believe should be restricted from public access to an Azure private container in the cloud where only those with a [shared access signature (SAS) token](https://docs.microsoft.com/en-us/azure/storage/common/storage-sas-overview) can access it. The concept of storing files in Azure is handled by [Azure blob storage](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blobs-introduction#blob-storage-resources) resources.

### What is an Azure Blog Storage?

Azure Blob storage is Microsoft's object storage solution for the cloud. Blob storage offers three types of resources:

* The storage account
* A container in the storage account
* A blob in a container

### What are Azure Storage Accounts?

A storage account provides a unique namespace in Azure for your data. Every object that you store in Azure Storage has an address that includes your unique account name.

### What are Azure Private Containers?

A container organizes a set of blobs, similar to a directory in a file system. A storage account can include an unlimited number of containers, and a container can store an unlimited number of blobs. We can also restrict access to a container by disabling public access to it and [granting limited access using shared access signatures (SAS)](https://docs.microsoft.com/en-us/azure/storage/common/storage-sas-overview). The specific SAS that we use is an Account SAS.

### What is an Account SAS?

An account SAS is secured with the storage account key. An account SAS delegates access to resources in one or more of the storage services.


## Deploying an Azure Account Storage and a Private container

I created an ARM template to create everything for you

* Download the following template: https://github.com/hunters-forge/Blacksmith/blob/azure/templates/azure/Storage-Account-Private-Container/azuredeploy.json
* [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
* Run the following command to create an Azure Storage Account and an Azure Private Container in it. Make sure you define your **Resource Group** , **Azure Storage Account Name** and **Azure Private Container Name**

```
az group deployment create --resource-group <resourcegroup> --template-file azuredeploy.json --parameters storageAccountName=<name> containerName=<name>
```

* Thats it! If you go to your [Azure Portal](https://portal.azure.com) > Resource Groups > GroupName, you will see the Azure Storage Account resource available.
* One thing to remember is that you can get the Account SAS token by checking your deployment output values. I created the template so that it creates one for you.

## Uploading Resources to Private Container

We can upload a file with the following Azure CLI command

```
az storage blob upload --container-name <container-name> --file <local-filename> --name <filename-on-target> --connection-string <connection-string-SAS-token>
```

We can also upload all the contents from a folder with the following Azure CLI command

```
az storage blob upload-batch -d <container-name> -s <day1/payloads> --destination-path <day1/> --connection-string <connection-string-SAS-token>
```

## Calling Private Resources from ARM Templates

All we need to do in the ARM templates is use the following URI syntax for every URL that we want to access. I like to set two parameters:

* **_artifactsLocation**: This is the Account Storage / Container URL (e.g https://name-of-storage-account.blob.core.windows.net/name-of-container/)
* **_artifactsLocationSasToken**: This is the Account SAS Token that you get after deploying your Azure Account Storage and Private container via the ARM template. Go to deployments, select your deployment and look at the Deployment Output values.

```
"[uri(parameters('_artifactsLocation'), concat('private-script.ps1', parameters('_artifactsLocationSasToken')))]"
```