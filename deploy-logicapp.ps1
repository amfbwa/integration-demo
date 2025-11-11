$deploymentFile = "$env:TEMP\demo-logicapp-package.zip"

if (Test-Path $deploymentFile) {
    Remove-Item $deploymentFile
    Write-Host "Gammal fil borttagen från '$deploymentFile'"
}

# 3.1: Bygg zip
7z a -tzip $deploymentFile ./logicapp/* -r "-xr!.git" "-xr!.vscode" -y

# 3.2: (om inte redan gjort) deploya Bicep:
#az deployment group create -g <rg> -f main.bicep -p name=<basnamn>

# 3.3: Zip-deploy till din app
az webapp deploy `
  --resource-group bw-lab-weu-rg-integration-demo `
  --name amf-bw-lab-demo-logicapp `
  --type zip `
  --src-path $deploymentFile
