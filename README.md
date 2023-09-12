# Azure Virtual Network Gateway Terraform module

Terraform module which creates Azure Virtual Network Peering on Azure.

These types of resources are supported:

* [Azure Virtual network](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)
* [Azure Network Security Group](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
* [Subnet Delegation](https://learn.microsoft.com/en-us/azure/virtual-network/subnet-delegation-overview)
* [User Defined Route](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview#user-defined)
* [Virtual network peering](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview)
* [NSG Flow Logs](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview)

## Terraform versions

Terraform 1.5.6 and newer.

## Additional information

This is a "composite module" used to create vnet, subnets, user defined routes, peering*, network security groups and NSG Flow Logs.

 - Peering is created only on "local" vnet. If you need to create a peering on local and remote vnets, use the module vnet-peering

## Usage

```hcl
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
```

More samples in examples folder