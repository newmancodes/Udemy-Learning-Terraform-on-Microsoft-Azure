terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.99.0"
    }
  }
}

provider "azurerm" {
    features {}
}

resource "azurerm_resource_group" "web_server_rg" {
    name = "web-rg"
    location = "UK South"
}
