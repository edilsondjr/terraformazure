variable "ARM_SUBSCRIPTION_ID" {}
variable "ARM_CLIENT_ID" {}
variable "ARM_SPN_PASS" {}
variable "ARM_TENANT_ID" {}

provider "azurerm" {
    version = "~>2.0"
    features {}
    subscription_id             = var.ARM_SUBSCRIPTION_ID
    client_id                   = var.ARM_CLIENT_ID
    client_secret               = var.ARM_SPN_PASS
    tenant_id                   = var.ARM_TENANT_ID
}

variable "availzone" {
    type    = string
    default = "westus2"
}

resource "azurerm_resource_group" "terr" {
    name = "terraformrg"
    location = var.availzone

    tags = {
        environment = "Terraform"
    }
}

#################### NETWORK ####################

resource "azurerm_virtual_network" "rtervirnet" {
    name = "tervirnet"
    location = var.availzone
    address_space = [ "10.0.0.0/16" ]
    resource_group_name = azurerm_resource_group.terr.name

    tags = {
        environment = "Terraform"
    }
}

resource "azurerm_subnet" "rtervirsubnet" {
    name = "tervirsubnet"
    resource_group_name = azurerm_resource_group.terr.name
    virtual_network_name = azurerm_virtual_network.rtervirnet.name
    address_prefixes = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "rterpubip" {
    name = "terpubip"
    location = var.availzone
    resource_group_name = azurerm_resource_group.terr.name
    allocation_method = "Dynamic"

    tags = {
    environment = "Terraform"
    }
}

resource "azurerm_network_security_group" "rtersecg" {
    name = "tersecg"
    location = var.availzone
    resource_group_name = azurerm_resource_group.terr.name

    tags = {
    environment = "Terraform"
    }
}

resource "azurerm_network_security_rule" "rtersecr" {
    name = "SSH"
    access = "Allow"
    destination_address_prefix = "*"
    destination_port_range = "22"
    direction = "Inbound"
    priority = 1001
    protocol = "Tcp"
    source_address_prefix = "*"
    source_port_range = "*"
    resource_group_name = azurerm_resource_group.terr.name
    network_security_group_name = azurerm_network_security_group.rtersecg.name
}

resource "azurerm_network_interface" "rternetint" {
    name = "ternetint"
    location = var.availzone
    resource_group_name = azurerm_resource_group.terr.name

    ip_configuration {
        name = "ternetintcfg"
        subnet_id = azurerm_subnet.rtervirsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.rterpubip.id
    }

    tags = {
    environment = "Terraform"
    }
}

resource "azurerm_network_interface_security_group_association" "rternetsecgass" {
    network_interface_id = azurerm_network_interface.rternetint.id
    network_security_group_id = azurerm_network_security_group.rtersecg.id
}

#################### BOOT DIAGNOSTICS ####################

## each storage account must have a unique name, random number will be generated ##
resource "random_id" "rterrandomid" {
    keepers = {
      resource_group = azurerm_resource_group.terr.name
    }

    byte_length = 8
}

resource "azurerm_storage_account" "rterstoracc" {
    name = "diag${random_id.rterrandomid.hex}"
    location = var.availzone
    resource_group_name = azurerm_resource_group.terr.name
    account_replication_type = "LRS"
    account_tier = "Standard"

    tags = {
    environment = "Terraform"
    }

}


#################### VM ####################

resource "tls_private_key" "rtersshkey" {
    algorithm = "RSA"
    rsa_bits = 4096
}

output "tls_private_key" {
    value = tls_private_key.rtersshkey.private_key_pem
}

resource "azurerm_linux_virtual_machine" "rterlinuxvm" {
    name = "terlinuxvm"
    location = var.availzone
    resource_group_name = azurerm_resource_group.terr.name
    network_interface_ids = [azurerm_network_interface.rternetint.id]
    size = "Standard_DS1_v2"

    os_disk {
        name = "terosdisk"
        caching = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }
    
    source_image_reference {
        publisher = "Canonical"
        offer = "UbuntuServer"
        sku = "18.04-LTS"
        version = "latest"
    }

    computer_name = "terlinuxvm"
    admin_username = "azureuser"
    disable_password_authentication = true

    admin_ssh_key {
        username = "azureuser"
        public_key = tls_private_key.rtersshkey.public_key_openssh
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.rterstoracc.primary_blob_endpoint
    }

    tags = {
    environment = "Terraform"
    }
}
