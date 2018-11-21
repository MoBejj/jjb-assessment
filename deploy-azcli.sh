#!/bin/bash

# Set parameters
resourceGroup="Sentia"
location="westeurope"
environment_Tag="TST"
company_Tag="Sentia"

# create resource group and tags
az group create --resource-group $resourceGroup --location $location
az group update -n Sentia --set tags.Environment=$environment_Tag tags.Company=$company_Tag

# the template we will deploy
templateUri="https://raw.githubusercontent.com/MoBejj/jjb-assessment/dev/azuredeploy.json"

# deploy, specifying all template parameters directly
az group deployment create \
    --resource-group $resourceGroup \
    --template-uri $templateUri \
    --parameters VirtualNetworkName=sentia-vNet01 \
                 StorageAccount_Prefix=sentia \
                 NumberOfSubnets=3

# create and assign AllowedResourceType policy
policyUri="https://raw.githubusercontent.com/MoBejj/jjb-assessment/dev/policies.json"

#Define Resourcegroup ID & SubscriptionID

scope_rg=$(az group show --name $resourceGroup)
sub=$(az account show)
id=$(echo $sub | jq '.id' -r)
scope_sub="/subscriptions/$id"


az policy definition create --name 'allowed-resourcetypes' --display-name 'Allowed resource types' --description 'This policy enables you to specify the resource types that your organization can deploy.' --rules $policyUri --mode All

# Assign policy to ResourceGrop
az policy assignment create --name 'allowed-resourcetypes-assignment' --scope `echo $scope_rg | jq '.id' -r` --policy allowed-resourcetypes 

# Assign policy to Subscription
az policy assignment create --name 'allowed-resourcetypes-assignment-sub' --scope `echo $scope_sub` --policy allowed-resourcetypes 