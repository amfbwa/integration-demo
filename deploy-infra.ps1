az deployment sub create `
    --location westeurope `
    --template-file ./infra/00-main.bicep `
    --parameters resourceGroupName=bw-lab-weu-rg-integration-demo

### Ta bort resursgruppen
# az group delete --name bw-lab-weu-rg-integration-demo
