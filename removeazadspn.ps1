$spn = Read-Host "Input SP Name"
Remove-AzureRmADServicePrincipal -ServicePrincipalName $spn
