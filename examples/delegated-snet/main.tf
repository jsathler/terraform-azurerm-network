locals {
  ipv4_cidr = "10.0.0.0/16"

  #First subnet /22 > /26, /26
  delegated_vnet_cidr  = cidrsubnet(local.ipv4_cidr, 6, 0)
  delegated_snet_cidrs = cidrsubnets(local.delegated_vnet_cidr, 4, 4)
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "default" {
  name     = "networking-delegated-rg"
  location = var.location
}

module "delegated-vnet" {
  source              = "../../"
  name                = "delegated"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = [local.delegated_vnet_cidr]

  subnets = {
    resolver-in = {
      address_prefixes   = [local.delegated_snet_cidrs[0]]
      nsg_create_default = false
      service_delegation = { name = "Microsoft.Network/dnsResolvers", actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"] }
    }
    resolver-out = {
      address_prefixes   = [local.delegated_snet_cidrs[1]]
      nsg_create_default = false
      service_delegation = { name = "Microsoft.Network/dnsResolvers", actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"] }
    }
  }
}
