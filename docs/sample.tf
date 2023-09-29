module "single-vnet" {
  source              = "jsathler/networking/azurerm"
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
