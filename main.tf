locals {
  tags                 = merge(var.tags, { ManagedByTerraform = "True" })
  special_subnet_names = ["GatewaySubnet", "AzureFirewallSubnet", "AzureFirewallManagementSubnet", "AzurebastionSubnet", "RouteServerSubnet"]
}

# vNet and Subnets
resource "azurerm_virtual_network" "default" {
  name                = "${var.name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = local.tags
}

resource "azurerm_subnet" "default" {
  for_each                                      = { for key, value in var.subnets : key => value }
  name                                          = contains(local.special_subnet_names, each.key) ? each.key : "${each.key}-snet"
  virtual_network_name                          = azurerm_virtual_network.default.name
  resource_group_name                           = var.resource_group_name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = each.value.service_endpoints
  service_endpoint_policy_ids                   = each.value.service_endpoint_policy_ids
  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled

  dynamic "delegation" {
    for_each = each.value.service_delegation != null ? [each.value.service_delegation] : []
    content {
      name = "delegation"
      service_delegation {
        name    = delegation.value.name
        actions = delegation.value.actions
      }
    }
  }
}

# vNet DNS
# Had to add the depends_on because for some reason terraform apply failed for the first execution
resource "azurerm_virtual_network_dns_servers" "default" {
  depends_on = [azurerm_subnet_network_security_group_association.default, azurerm_subnet_route_table_association.default]
  count      = var.dns_servers == null ? 0 : 1

  virtual_network_id = azurerm_virtual_network.default.id
  dns_servers        = var.dns_servers
}

# User Defined Route
locals {
  #Var to simplify user input and keep the "standard" resource_name = properties
  routes = flatten([
    for table_key, table_value in var.route_table : [
      for route_key, route_value in table_value.routes : {
        route_name             = route_key
        route_table_name       = table_key
        address_prefix         = route_value.address_prefix
        next_hop_type          = route_value.next_hop_type
        next_hop_in_ip_address = route_value.next_hop_in_ip_address
      }
    ]
  ])
}

resource "azurerm_route_table" "default" {
  for_each                      = { for key, value in var.route_table : key => value }
  name                          = "${each.key}-route"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = each.value.disable_bgp_route_propagation
  tags                          = local.tags
}

resource "azurerm_route" "default" {
  for_each               = { for key, value in local.routes : value.route_name => value }
  name                   = "${each.key}-rt"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.default[each.value.route_table_name].name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}

resource "azurerm_subnet_route_table_association" "default" {
  for_each       = { for key, value in var.subnets : key => value if value.route_table_name != null }
  subnet_id      = azurerm_subnet.default[each.key].id
  route_table_id = azurerm_route_table.default[each.value.route_table_name].id
}

# Peerings on local vnet. If you need to create a peering on both vnets, use the module vnet-peering
resource "azurerm_virtual_network_peering" "default" {
  for_each                     = { for peering in var.local_peering : peering.remote_virtual_network_id => peering }
  name                         = each.value.peering_name != null ? "${each.value.peering_name}-vpeer" : "${split("/", each.value.vnet_id)[8]}-vpeer"
  resource_group_name          = azurerm_virtual_network.default.resource_group_name
  virtual_network_name         = azurerm_virtual_network.default.name
  remote_virtual_network_id    = each.value.vnet_id
  allow_virtual_network_access = each.value.allow_virtual_network_access
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = each.value.allow_gateway_transit
  use_remote_gateways          = each.value.use_remote_gateways
}

# Network Security Group
resource "azurerm_network_security_group" "default" {
  for_each            = { for key, value in var.subnets : key => value if value.nsg_create_default }
  name                = "${each.key}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "default" {
  for_each                  = { for key, value in var.subnets : key => value if value.nsg_create_default }
  subnet_id                 = azurerm_subnet.default[each.key].id
  network_security_group_id = azurerm_network_security_group.default[each.key].id
}

# Network Security Group explict deny rules
resource "azurerm_network_security_rule" "explicit_inbound" {
  for_each                    = { for key, value in var.subnets : key => value if value.nsg_create_default && value.nsg_create_explicit_in_rule }
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.default[each.key].name
  name                        = "explicit-in-deny"
  description                 = "Explicit inbound deny"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "VirtualNetwork"
}

resource "azurerm_network_security_rule" "explicit_azlb" {
  for_each                    = { for key, value in var.subnets : key => value if value.nsg_create_default && value.nsg_create_explicit_in_rule }
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.default[each.key].name
  name                        = "AllowAzureLoadBalancerInBound"
  description                 = "Explicit Azure Load Balancer inbound allow"
  priority                    = 4095
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "VirtualNetwork"
}

resource "azurerm_network_security_rule" "explicit_outbound" {
  for_each                    = { for key, value in var.subnets : key => value if value.nsg_create_default && value.nsg_create_explicit_out_rule }
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.default[each.key].name
  name                        = "explicit-out-deny"
  description                 = "Explicit outbound deny"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
}

# Network Security Group Flow Logs
resource "azurerm_network_watcher_flow_log" "default" {
  for_each             = { for key, value in var.subnets : key => value if value.nsg_create_default && var.network_flow_log != null }
  name                 = "${each.key}-netflowlog"
  network_watcher_name = var.network_flow_log.name
  resource_group_name  = var.network_flow_log.resource_group_name

  network_security_group_id = azurerm_network_security_group.default[each.key].id
  storage_account_id        = var.network_flow_log.storage_account_id
  enabled                   = true
  version                   = 2

  retention_policy {
    enabled = true
    days    = var.network_flow_log.retention_in_days
  }

  dynamic "traffic_analytics" {
    for_each = var.network_flow_log.traffic_analytics_workspace_enabled ? [var.network_flow_log] : []
    content {
      enabled               = true
      workspace_id          = traffic_analytics.value.traffic_analytics_workspace_id
      workspace_region      = traffic_analytics.value.traffic_analytics_workspace_location
      workspace_resource_id = traffic_analytics.value.traffic_analytics_workspace_resource_id
      interval_in_minutes   = traffic_analytics.value.traffic_analytics_workspace_inverval
    }
  }

  tags = local.tags
}
