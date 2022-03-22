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

module "location_uks" {
    source = "./location"

    web_server_location         = "uksouth"
    web_server_rg               = "${var.web_server_rg}-uksouth"
    resource_prefix             = "${var.resource_prefix}-uksouth"
    web_server_address_space    = "1.0.0.0/22"
    web_server_name             = var.web_server_name
    environment                 = var.environment
    web_server_count            = var.web_server_count
    web_server_subnets          = {
        web-server              = "1.0.1.0/24"
        AzureBastionSubnet      = "1.0.2.0/24"
    }
    terraform_script_version    = var.terraform_script_version
    admin_password              = data.azurerm_key_vault_secret.admin_password.value
    domain_name_label           = var.domain_name_label
}

module "location_ukw" {
    source = "./location"

    web_server_location         = "ukwest"
    web_server_rg               = "${var.web_server_rg}-ukwest"
    resource_prefix             = "${var.resource_prefix}-ukwest"
    web_server_address_space    = "2.0.0.0/22"
    web_server_name             = var.web_server_name
    environment                 = var.environment
    web_server_count            = var.web_server_count
    web_server_subnets          = {
        web-server              = "2.0.1.0/24"
        AzureBastionSubnet      = "2.0.2.0/24"
    }
    terraform_script_version    = var.terraform_script_version
    admin_password              = data.azurerm_key_vault_secret.admin_password.value
    domain_name_label           = var.domain_name_label
}

resource "azurerm_resource_group" "global_rg" {
    name        = "traffic-manager-rg"
    location    = "uksouth"
}

resource "azurerm_traffic_manager_profile" "traffic_manager" {
    name                    = "${var.resource_prefix}-traffic-manager"
    resource_group_name     = azurerm_resource_group.global_rg.name
    traffic_routing_method  = "Weighted"

    dns_config {
        relative_name       = var.domain_name_label
        ttl                 = 100
    }

    monitor_config {
        protocol            = "http"
        port                = 80
        path                = "/"
    }
}

resource "azurerm_traffic_manager_azure_endpoint" "traffic_manager_uks" {
    name                = "${var.resource_prefix}-traffic-manager-uks-endpoint"
    profile_id          = azurerm_traffic_manager_profile.traffic_manager.id
    target_resource_id  = module.location_uks.web_server_lb_public_ip_id
    weight              = 50
}

resource "azurerm_traffic_manager_azure_endpoint" "traffic_manager_ukw" {
    name                = "${var.resource_prefix}-traffic-manager-ukw-endpoint"
    profile_id          = azurerm_traffic_manager_profile.traffic_manager.id
    target_resource_id  = module.location_ukw.web_server_lb_public_ip_id
    weight              = 50
}
