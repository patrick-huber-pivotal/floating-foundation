terraform {
  required_version = ">= 0.12.0"
}

provider "azurerm" {
}

resource "azurerm_resource_group" "main" {
  name     = "floating-foundation"
  location = "westus"
}

module "network_westus" {
  source              = "./modules/networks"
  resource_group_name = azurerm_resource_group.main.name
  location            = "westus"
  network_name        = "floating-westus"
  network_cidr        = "10.0.0.0/16"
}

module "subnet_public_westus" {
  source              = "./modules/subnets"
  resource_group_name = azurerm_resource_group.main.name
  location            = "westus"
  network_name        = module.network_westus.virtual_network_name
}