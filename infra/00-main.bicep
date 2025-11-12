
targetScope = 'subscription'

param location string = 'westeurope'
param resourceGroupName string = 'bw-lab-weu-rg-integration-demo'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}


module workflowsModule './10-workflows.bicep' = {
  name: 'workflows'
  scope: resourceGroup
  params: {
    location: location
  }
}

output subscriptionId string = subscription().id
output subscriptionName string = subscription().displayName
output workflowResources object = workflowsModule.outputs

