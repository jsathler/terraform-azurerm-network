/*
This example will create three vnets with different subnets requirements

A peering between hub x shared and hub x prd will be created in order to enable the "hub and spoke architecture"

Flow Logs will be enabled on subnets in prd and shared vnets

If you have multiple subscriptions, provide the subscription ids in locals and uncomment them. Remember to uncomment "subscription_id" in the provider blocks

*/
locals {
  # hub_subscription_id    = ""
  # shared_subscription_id = ""
  # prd_subscription_id    = ""

  ipv4_cidr = "10.0.0.0/16"

  #First subnet /22 > /26, /26, /26
  hub_vnet_cidr  = cidrsubnet(local.ipv4_cidr, 6, 0)
  hub_snet_cidrs = cidrsubnets(local.hub_vnet_cidr, 4, 4, 4)

  #Second subnet /22 > /26, /26, /26
  shared_vnet_cidr  = cidrsubnet(local.ipv4_cidr, 6, 1)
  shared_snet_cidrs = cidrsubnets(local.shared_vnet_cidr, 3, 3)

  # Second subnet /19 > /24, /23, /23
  prd_vnet_cidr  = cidrsubnet(local.ipv4_cidr, 3, 1)
  prd_snet_cidrs = cidrsubnets(local.prd_vnet_cidr, 5, 4, 4)

  default_remote_gw   = cidrhost(local.hub_snet_cidrs[1], 4)
  default_dns_servers = [cidrhost(local.shared_snet_cidrs[0], 4), cidrhost(local.shared_snet_cidrs[0], 5)]

  default_route_table = {
    disable_bgp_route_propagation = true
    routes = {
      default = {
        address_prefix         = "0.0.0.0/0"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = local.default_remote_gw
      }
      azurebackup = {
        address_prefix = "AzureBackup"
        next_hop_type  = "Internet"
      }
    }
  }

  appgateway_route_table = {
    disable_bgp_route_propagation = true
    routes = {
      internet = {
        address_prefix = "0.0.0.0/0"
        next_hop_type  = "Internet"
      }
      rfc1918-10 = {
        address_prefix         = "10.0.0.0/8"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = local.default_remote_gw
      }
      rfc1918-172 = {
        address_prefix         = "172.16.0.0/12"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = local.default_remote_gw
      }
      rfc1918-192 = {
        address_prefix         = "192.168.0.0/16"
        next_hop_type          = "VirtualAppliance"
        next_hop_in_ip_address = local.default_remote_gw
      }
    }
  }
}

provider "azurerm" {
  features {}
  #subscription_id = local.hub_subscription_id
}

provider "azurerm" {
  features {}
  #subscription_id = local.shared_subscription_id
  alias = "shared"
}

provider "azurerm" {
  features {}
  #subscription_id = local.prd_subscription_id
  alias = "prd"
}

resource "azurerm_resource_group" "hub" {
  name     = "networking-hub-rg"
  location = var.location
}

resource "azurerm_resource_group" "shared" {
  name     = "networking-shared-rg"
  location = var.location
  provider = azurerm.shared
}

resource "azurerm_resource_group" "prd" {
  name     = "networking-prd-rg"
  location = var.location
  provider = azurerm.prd
}

resource "azurerm_resource_group" "logging_shared" {
  name     = "logging-shared-rg"
  location = var.location
  provider = azurerm.shared
}

resource "random_string" "default" {
  length    = 6
  min_lower = 6
}

resource "azurerm_storage_account" "default" {
  name                     = "hubspoke${random_string.default.result}nflowsa"
  location                 = azurerm_resource_group.logging_shared.location
  resource_group_name      = azurerm_resource_group.logging_shared.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_log_analytics_workspace" "default" {
  name                = "hubspoke-log"
  location            = azurerm_resource_group.logging_shared.location
  resource_group_name = azurerm_resource_group.logging_shared.name
}

module "hub-vnet" {
  source              = "../../"
  name                = "hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = [local.hub_vnet_cidr]
  dns_servers         = local.default_dns_servers

  subnets = {
    GatewaySubnet = {
      address_prefixes   = [local.hub_snet_cidrs[0]]
      nsg_create_default = false
      route_table_name   = "gatewaysubnet"
    }
    AzureFirewallSubnet = {
      address_prefixes   = [local.hub_snet_cidrs[1]]
      nsg_create_default = false
    }
  }

  route_table = {
    gatewaysubnet = {
      disable_bgp_route_propagation = false
      routes = {
        shared-vnet = {
          address_prefix         = local.shared_vnet_cidr
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = local.default_remote_gw
        }
        prd-vnet = {
          address_prefix         = local.prd_vnet_cidr
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = local.default_remote_gw
        }
      }
    }
  }
}

module "shared-vnet" {
  source = "../../"

  providers = {
    azurerm = azurerm.shared
  }

  name                = "shared"
  location            = azurerm_resource_group.shared.location
  resource_group_name = azurerm_resource_group.shared.name
  address_space       = [local.shared_vnet_cidr]
  dns_servers         = local.default_dns_servers

  subnets = {
    infra-shared = {
      address_prefixes            = [local.shared_snet_cidrs[0]]
      route_table_name            = "default-shared"
      nsg_create_explicit_in_rule = false
    }
    jumpbox-shared = {
      address_prefixes = [local.shared_snet_cidrs[1]]
      route_table_name = "default-shared"
    }
  }

  route_table = {
    default-shared = local.default_route_table
  }

  network_flow_log = {
    storage_account_id                      = azurerm_storage_account.default.id
    traffic_analytics_workspace_enabled     = true
    traffic_analytics_workspace_id          = azurerm_log_analytics_workspace.default.workspace_id
    traffic_analytics_workspace_resource_id = azurerm_log_analytics_workspace.default.id
  }
}

module "prd-vnet" {
  source = "../../"

  providers = {
    azurerm = azurerm.prd
  }

  name                = "prd"
  location            = azurerm_resource_group.prd.location
  resource_group_name = azurerm_resource_group.prd.name
  address_space       = [local.prd_vnet_cidr]
  dns_servers         = local.default_dns_servers

  subnets = {
    appgateway-prd = {
      address_prefixes = [local.prd_snet_cidrs[0]]
      route_table_name = "appgateway-prd"
    }
    app-prd = {
      address_prefixes = [local.prd_snet_cidrs[1]]
      route_table_name = "default-prd"
    }
    db-prd = {
      address_prefixes = [local.prd_snet_cidrs[2]]
      route_table_name = "default-prd"
    }
  }

  route_table = {
    default-prd    = local.default_route_table
    appgateway-prd = local.appgateway_route_table
  }

  network_flow_log = {
    storage_account_id                      = azurerm_storage_account.default.id
    traffic_analytics_workspace_enabled     = true
    traffic_analytics_workspace_id          = azurerm_log_analytics_workspace.default.workspace_id
    traffic_analytics_workspace_resource_id = azurerm_log_analytics_workspace.default.id
  }
}

module "shared-hub-peering" {
  source = "jsathler/vnet-peering/azurerm"

  providers = {
    azurerm.local-vnet  = azurerm.shared
    azurerm.remote-vnet = azurerm
  }

  local_vnet  = { vnet_id = module.shared-vnet.vnet_id, use_remote_gateways = false }
  remote_vnet = { vnet_id = module.hub-vnet.vnet_id, allow_gateway_transit = false }
}

module "prd-hub-peering" {
  source = "jsathler/vnet-peering/azurerm"

  providers = {
    azurerm.local-vnet  = azurerm.prd
    azurerm.remote-vnet = azurerm
  }

  local_vnet  = { vnet_id = module.prd-vnet.vnet_id, use_remote_gateways = false }
  remote_vnet = { vnet_id = module.hub-vnet.vnet_id, allow_gateway_transit = false }
}
