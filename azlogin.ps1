$Tenant = (Get-Childitem env:ARM_TENANT_ID).value
$spName = (Get-Childitem env:ARM_CLIENT_ID).value
$Pass = (Get-Childitem env:ARM_SPN_PASS).value
az login --service-principal -u $spName -p $Pass --tenant $Tenant