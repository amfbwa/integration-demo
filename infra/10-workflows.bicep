param location string = resourceGroup().location

var contentShareName = 'workflows'

resource plan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: 'demo-logicapp-plan'
  location: location
  kind: 'elastic'
  sku: {
    tier: 'WorkflowStandard'
    name: 'WS1'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'demostorage${uniqueString(subscription().id, resourceGroup().name, 'demo-storage')}'
  location: location
  sku: { name: 'Standard_LRS' }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
  }
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = {
  name: '${storageAccount.name}/default/${contentShareName}'
  properties: {
    // Minsta möjliga – ingen kvota/TTL etc.
  }
}

var saKeys = listKeys(storageAccount.id, '2023-01-01')
var saConn = 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${saKeys.keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
var wfLocation = toLower(replace(location, ' ', '')) // ex: 'westeurope'

resource logicApp 'Microsoft.Web/sites@2023-12-01' = {
  name: 'amf-bw-lab-demo-logicapp-2'
  location: location
  kind: 'functionapp,workflowapp'
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      appSettings: [
        // Obligatoriska för runtime + innehåll på Azure Files
        { name: 'AzureWebJobsStorage', value: saConn }

        // Inställningar som är Logic Apps-specifika
        { name: 'APP_KIND', value: 'workflowApp' }
        { name: 'AzureFunctionsJobHost__extensionBundle__id', value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows' }
        { name: 'AzureFunctionsJobHost__extensionBundle__version', value: '[1.*, 2.0.0)' }
        { name: 'WORKFLOWS_TENANT_ID', value: tenant().tenantId }
        { name: 'WORKFLOWS_SUBSCRIPTION_ID', value: subscription().subscriptionId }
        { name: 'WORKFLOWS_RESOURCE_GROUP_NAME', value: resourceGroup().name }
        { name: 'WORKFLOWS_LOCATION_NAME', value: wfLocation }

        { name: 'WEBSITE_NODE_DEFAULT_VERSION', value: '~22' }
        

        // Workflows ska läsas från den File Share vi skapat i Storage Account
        { name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING', value: saConn }
        { name: 'WEBSITE_CONTENTSHARE', value: contentShareName }

        // Andra miljövariabler som Functions Runtime (LA standard körs ovanpå den) kräver
        { name: 'FUNCTIONS_EXTENSION_VERSION', value: '~4' }
        { name: 'FUNCTIONS_WORKER_RUNTIME', value: 'dotnet'}

        // Tidigare använt i experimentsyfte
        // { name: 'WEBSITE_RUN_FROM_PACKAGE', value: '1' }
      ]
    }
    httpsOnly: true
  }
  // dependsOn: [
  //   fileShare
  // ]
}

output resourceGroup string = resourceGroup().name
output storageAccountName string = storageAccount.name
output logicAppName string = logicApp.name
output fileshareName string = fileShare.name
