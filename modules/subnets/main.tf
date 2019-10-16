resource "azurerm_subnet" "public" {
    name                 = "${var.network_name}-public"
    resource_group_name  = var.resource_group_name
    virtual_network_name = var.network_name
    address_prefix       = var.subnet_cidr_public
}

resource "azurerm_subnet" "private" {
    name                 = "${var.network_name}-private"
    resource_group_name  = var.resource_group_name
    virtual_network_name = var.network_name
    address_prefix       = var.subnet_cidr_private
}