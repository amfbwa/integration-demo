Write-Host "Deployment av logic app startar"

$infraResponseJsonFile = "$env:TEMP\integration-demo-infra.json"

Write-Host "Läser in fil från infra deployment: '$infraResponseJsonFile'"

$infraResponseObject = Get-Content -Path $infraResponseJsonFile | ConvertFrom-Json

$workflowResources = $infraResponseObject.properties.outputs.workflowResources.value

$resourceGroup = $workflowResources.resourceGroup.value
$storageAccount = $workflowResources.storageAccountName.value
$fileshare = ($workflowResources.fileshareName.value -split '/')[-1]
$logicAppName = $workflowResources.logicAppName.value
$storageAccountKey = az storage account keys list -g $resourceGroup -n $storageAccount --query "[0].value" -o tsv

Write-Host "Skapar upp rotkatalogen (om den inte redan finns)"
az storage directory create --account-name $storageAccount --account-key $storageAccountKey --share-name $fileshare --name "site/wwwroot"

# az storage directory delete --account-name $accountName --account-key $accountKey --share-name $fileshare --name "site/wwwroot" --recursive --fail-not-exist

Write-Host "Laddar upp workflows"
az storage file upload-batch --account-name $storageAccount --account-key $storageAccountKey --destination $fileshare --destination-path site/wwwroot --source ".\logicapp" --pattern "*"

Write-Host "Startar om Logic App '$logicAppName'"
az webapp restart -g $resourceGroup -n $logicAppName

Write-Host "Deployment av logic app klar"
