terraform {
  required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version = "=2.99.0"
    }
    random = {
        source = "hashicorp/random"
        version = "=3.1.2"
    }
  }
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "bastion_rg" {
    name        = var.bastion_rg
    location    = var.location
}

resource "azurerm_public_ip" "bastion_pip" {
    name                = "bastion-ip"
    location            = var.location
    resource_group_name = var.bastion_rg
    allocation_method   = "Static"
    sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion_host" {
    name                        = "bastion-host"
    location                    = var.location
    resource_group_name         = var.bastion_rg

    ip_configuration {
        name                    = "uksouth"
        subnet_id               = data.terraform_remote_state.web.outputs.bastion_host_subnet_uks
        public_ip_address_id    = azurerm_public_ip.bastion_pip.id
    }
}
