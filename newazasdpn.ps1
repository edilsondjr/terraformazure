
$Subscriptionid = (get-azsubscription).subscriptionid
$Tenantid = (get-azsubscription).id
$Scope = "/subscriptions/"+$Tenantid

$sp = New-AzADServicePrincipal -Scope $Scope
$spn = $sp.ServicePrincipalNames
$UnsecureSecret = ConvertFrom-SecureString -SecureString $sp.Secret -AsPlainText

$env:ARM_CLIENT_ID=$spn
$env:ARM_SUBSCRIPTION_ID=$Subscriptionid
$env:ARM_TENANT_ID=$Tenantid
$env:ARM_SPN_PASS=$UnsecureSecret