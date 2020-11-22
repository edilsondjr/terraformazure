$Tenant = (Get-Childitem env:ARM_TENANT_ID).value
$spName = (Get-Childitem env:ARM_CLIENT_ID).value
$Pass = (Get-Childitem env:ARM_SPN_PASS).value

$spPassword = ConvertTo-SecureString $Pass -AsPlainText -Force
$spCredential = New-Object System.Management.Automation.PSCredential($spName , $spPassword)

Connect-AzAccount -Credential $spCredential -Tenant $Tenant -ServicePrincipal
