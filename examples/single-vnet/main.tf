locals {
  ipv4_cidr = "10.0.0.0/16"

  #First subnet /22 > /26, /26, /26
  single_vnet_cidr  = cidrsubnet(local.ipv4_cidr, 6, 0)
  single_snet_cidrs = cidrsubnets(local.single_vnet_cidr, 4, 4, 4)
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "networking-single-rg"
  location = var.location
}

module "single-vnet" {
  source              = "../../"
  name                = "single"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = [local.single_vnet_cidr]

  subnets = {
    GatewaySubnet = {
      address_prefixes   = [local.single_snet_cidrs[0]]
      nsg_create_default = false
    }
    AzureFirewallSubnet = {
      address_prefixes   = [local.single_snet_cidrs[1]]
      nsg_create_default = false
    }
  }
}
