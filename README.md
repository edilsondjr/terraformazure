For use with Terraform (SPN Authentication)

Create environment variables:

POWERSHELL:
$env:TF_VAR_ARM_CLIENT_ID="<SPN_APPID>"
$env:TF_VAR_ARM_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
$env:TF_VAR_ARM_TENANT_ID="<TENANT_ID>"
$env:TF_VAR_ARM_SPN_PASS="<SPN_PASS>"


To Create:
terraform plan -out plan.tfplan
terraform apply plan.tfplan

To Destroy:
terraform plan -out plan.destroy.tfplan
terraform apply plan.destroy.tfplan
