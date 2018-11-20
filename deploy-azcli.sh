#!/bin/bash

resourceGroup="SentiaTST"
location="westeurope"
environment_Tag="TST"
company_Tag="Sentia"

# create resource group and tags
az group create --resource-group $resourceGroup-l --location $location
az group update -n Sentia --set tags.Environment=$environment_Tag tags.Company=$company_Tag

# the template we will deploy
templateUri="https://raw.githubusercontent.com/MoBejj/jjb-assessment/dev/azuredeploy.json"

# deploy, specifying all template parameters directly
az group deployment validate \
    --resource-group $resourceGroup \
    --template-uri $templateUri \
    --parameters VirtualNetworkName=sentia-vNet01 \
                 StorageAccount_Prefix=sentia \
                 NumberOfSubnets=3

# create and assign AllowedResourceType policy
policyUri="https://raw.githubusercontent.com/MoBejj/jjb-assessment/dev/policies.json"
az policy assignment create --policy AllowedResourceTypes -p $policyUri