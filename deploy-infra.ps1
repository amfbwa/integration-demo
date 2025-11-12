Write-Host "Infra deployment startar"

$infraResponseJsonFile = "$env:TEMP\integration-demo-infra.json"

$infraResponseJson = az deployment sub create `
    --location westeurope `
    --template-file ./infra/00-main.bicep `
    --parameters resourceGroupName=bw-lab-weu-rg-integration-demo

$infraResponseJson > "$infraResponseJsonFile"

Write-Host "Azure infra deployment output: '$infraResponseJsonFile'"

### Ta bort resursgruppen
# az group delete --name bw-lab-weu-rg-integration-demo

Write-Host "Infra deployment klar"
