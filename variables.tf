variable "location" {
  description = "The region where the VM will be created. This parameter is required"
  type        = string
  default     = "northeurope"
}

variable "name" {
  description = "Virtual network name. This parameter is required"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created. This parameter is required"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to resources."
  type        = map(string)
  default     = null
}

variable "address_space" {
  type = list(string)
}

variable "dns_servers" {
  type    = list(string)
  default = null
}

variable "subnets" {
  description = "Virtual machine's name. This parameter is required"
  type = map(object({
    address_prefixes             = list(string),
    route_table_name             = optional(string, null)
    service_endpoints            = optional(list(string), null)
    nsg_create_default           = optional(bool, true)
    nsg_create_explicit_in_rule  = optional(bool, true)
    nsg_create_explicit_out_rule = optional(bool, false)
    service_endpoint_policy_ids  = optional(list(string), null)
    service_delegation = optional(object({
      name    = string
      actions = optional(list(string), null)
    }), null)
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
  }))
  default = {}
}

variable "route_table" {
  type = map(object({
    disable_bgp_route_propagation = optional(bool, false)
    routes = map(object({
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string, null)
    }))
  }))
  default = {}
}

variable "local_peering" {
  description = "vNet ID(s) to create peering on this vnet, the peering will be created only on local vNet. This can be usefull if you need to establish a peering between this and other vnets but have no controll on remote vNet"
  type = list(object({
    vnet_id                      = string
    peering_name                 = optional(string, null)
    allow_virtual_network_access = optional(bool, true)
    allow_forwarded_traffic      = optional(bool, false)
    allow_gateway_transit        = optional(bool, false)
    use_remote_gateways          = optional(bool, false)
  }))
  default = []
}

variable "network_flow_log" {
  description = "Network flow log parameters. Defaults to 'northeurope' region but requires the storage account id"

  type = object({
    name                                    = optional(string, "NetworkWatcher_northeurope")
    resource_group_name                     = optional(string, "NetworkWatcherRG")
    storage_account_id                      = optional(string, null)
    retention_in_days                       = optional(number, 7)
    traffic_analytics_workspace_enabled     = optional(bool, false)
    traffic_analytics_workspace_id          = optional(string, null)
    traffic_analytics_workspace_location    = optional(string, "northeurope")
    traffic_analytics_workspace_resource_id = optional(string, null)
    traffic_analytics_workspace_inverval    = optional(number, 10)
  })

  default = null
}


