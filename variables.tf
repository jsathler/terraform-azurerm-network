variable "location" {
  description = "The region where the Virtual Network will be created. This parameter is required"
  type        = string
  default     = "northeurope"
}

variable "name" {
  description = "Virtual network name. This parameter is required"
  type        = string
  nullable    = false
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created. This parameter is required"
  type        = string
  nullable    = false
}

variable "tags" {
  description = "Tags to be applied to resources."
  type        = map(string)
  default     = null
}

variable "address_space" {
  description = "A list of the Virtual Network address space(s). This parameter is required"
  type        = list(string)
  nullable    = false
}

variable "dns_servers" {
  description = "A list of DNS Server IP(s). This parameter is optional"
  type        = list(string)
  default     = null
}

variable "bgp_community" {
  description = "The BGP community attribute in format <as-number>:<community-value>"
  type        = string
  default     = null
}

variable "flow_timeout_in_minutes" {
  description = "The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes"
  type        = number
  default     = null
}

variable "subnets" {
  description = <<DESCRIPTION
  A map of Subnets. This parameter is required
  - address_prefixes                              (required) The address prefixes to use for the subnet
  - route_table_name                              (optional) The route table name to be associated to this subnet. Defaults to null
  - service_endpoints                             (optional) The list of Service endpoints to associate with the subnet. Defaults to null
  - nsg_create_default                            (optional) Define if a NSG should be created for this subnet. Defaults to true
  - nsg_create_explicit_in_rule                   (optional) Define if a default explicit deny inbound rule should be created. Defaults to true
  - nsg_create_explicit_out_rule                  (optional) Define if a default explicit deny outbound rule should be created. Defaults to false
  - service_endpoint_policy_ids                   (optional) The list of IDs of Service Endpoint Policies to associate with the subnet. Defaults to null
  - service_delegation                            (optional) A block as defined bellow
    - name                                        (required) The name of service to delegate to
    - actions                                     (optional) A list of Actions which should be delegated. This list is specific to the service to delegate to
  - private_endpoint_network_policies             (optional) Enable or Disable network policies for the private endpoint on the subnet. Possible values are Disabled, Enabled, NetworkSecurityGroupEnabled and RouteTableEnabled. Defaults to Enabled
  - private_link_service_network_policies_enabled (optional) Enable or Disable network policies for the private link service on the subnet. Defaults to true
  - nsg_rules:                                    (optional) A block as defined bellow
    - description                                 (optional) A description for this rule. Restricted to 140 characters
    - protocol                                    (optional) Network protocol this rule applies to. Possible values include Tcp, Udp, Icmp, Esp, Ah or '*'. Defaults to TCP
    - priority                                    (required) Specifies the priority of the rule. The value can be between 100 and 4096
    - direction                                   (optional) The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are Inbound and Outbound. Defaults to "Inbound"
    - access                                      (optional) Specifies whether network traffic is allowed or denied. Possible values are Allow and Deny. Defaults to Allow
    - source_port_range                           (optional) Source Port or Range. Integer or range between 0 and 65535 or * to match any. Defaults to '*'
    - source_port_ranges                          (optional) List of source ports or port ranges
    - destination_port_range                      (optional) Destination Port or Range. Integer or range between 0 and 65535 or * to match any. This is required if destination_port_ranges is not specified
    - destination_port_ranges                     (optional) List of destination ports or port ranges. This is required if destination_port_range is not specified
    - source_address_prefix                       (optional) CIDR or source IP range or * to match any IP. Tags such as VirtualNetwork, AzureLoadBalancer and Internet can also be used. This is required if source_address_prefixes or source_application_security_group_ids is not specified
    - source_address_prefixes                     (optional) List of source address prefixes. Tags may not be used. This is required if source_address_prefix or source_application_security_group_ids is not specified
    - destination_address_prefix                  (optional) CIDR or destination IP range or * to match any IP. Tags such as VirtualNetwork, AzureLoadBalancer and Internet can also be used. Besides, it also supports all available Service Tags like ‘Sql.WestEurope‘, ‘Storage.EastUS‘, etc. This is required if destination_address_prefixes or destination_application_security_group_ids is not specified
    - destination_address_prefixes                (optional) List of destination address prefixes. Tags may not be used. This is required if destination_address_prefix or destination_application_security_group_ids is not specified
    - source_application_security_group_ids       (optional) A List of source Application Security Group IDs
    - destination_application_security_group_ids  (optional) A List of destination Application Security Group IDs
  DESCRIPTION

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
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, true)
    nsg_rules = optional(map(object({
      description                                = optional(string),
      protocol                                   = optional(string, "Tcp"),
      priority                                   = number,
      direction                                  = optional(string, "Inbound"),
      access                                     = optional(string, "Allow"),
      source_port_range                          = optional(string, "*"),
      source_port_ranges                         = optional(list(string), null),
      destination_port_range                     = optional(string, null),
      destination_port_ranges                    = optional(list(string), null),
      source_address_prefix                      = optional(string, null),
      source_address_prefixes                    = optional(list(string), null),
      destination_address_prefix                 = optional(string, null),
      destination_address_prefixes               = optional(list(string), null),
      source_application_security_group_ids      = optional(list(string), null),
      destination_application_security_group_ids = optional(list(string), null)
    })), null)
  }))

  nullable = false
}

variable "route_table" {
  description = <<DESCRIPTION
  A map of route tables. This parameter is optional
   - bgp_route_propagation_enabled  (optional) Boolean flag which controls propagation of routes learned by BGP on that route table. Defaults to false
   - routes                         (optional) A block as defined bellow
    - address_prefix                (required) The destination to which the route applies. Can be CIDR (such as 10.1.0.0/16) or Azure Service Tag (such as ApiManagement, AzureBackup or AzureMonitor) format
    - next_hop_type                 (required) The type of Azure hop the packet should be sent to. Possible values are VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance and None
    - next_hop_in_ip_address        (optional) Contains the IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is VirtualAppliance. Defaults to null
  DESCRIPTION  
  type = map(object({
    bgp_route_propagation_enabled = optional(bool, false)
    routes = map(object({
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string, null)
    }))
  }))
  default  = {}
  nullable = false
}

variable "local_peering" {
  description = <<DESCRIPTION
  A list of vNet ID(s) to create peering on this vnet, the peering will be created only on local vNet. This parameter is optional
  This can be usefull if you need to establish a peering between this and other vnets but have no controll on remote vNet
   - vnet_id:                       (required) The full Azure resource ID of the remote virtual network
   - peering_name:                  (optional) If not defined, the vnet name will be used in the peering name
   - allow_virtual_network_access:  (optional) Controls if the VMs in the remote virtual network can access VMs in the local virtual network. Defaults to true
   - allow_forwarded_traffic:       (optional) Controls if forwarded traffic from VMs in the remote virtual network is allowed. Defaults to false
   - allow_gateway_transit:         (optional) Controls gatewayLinks can be used in the remote virtual network’s link to the local virtual network. Defaults to false
   - use_remote_gateways:           (optional) Controls if remote gateways can be used on the local virtual network. Defaults to false
  DESCRIPTION
  type = list(object({
    vnet_id                      = string
    peering_name                 = optional(string, null)
    allow_virtual_network_access = optional(bool, true)
    allow_forwarded_traffic      = optional(bool, false)
    allow_gateway_transit        = optional(bool, false)
    use_remote_gateways          = optional(bool, false)
  }))
  default  = []
  nullable = false
}

variable "network_flow_log" {
  description = <<DESCRIPTION
  Network flow log parameters. This parameter is optional
   - name                         (optional) The name of the Network Watcher Flow Log. Defaults to "NetworkWatcher_northeurope"
   - resource_group_name          (optional) The name of the resource group in which the Network Watcher was deployed. Defaults to "NetworkWatcherRG"
   - storage_account_id           (required) The ID of the Storage Account where flow logs are stored
   - retention_in_days            (optional) The number of days to retain flow log records. Defaults to 7
   - traffic_analytics_workspace  (optional) A block as defined bellow
   - id                           (required) The resource GUID of the attached workspace 
   - location                     (optional) The location of the attached workspace. Defaults to "North Europe"
   - resource_id                  (required) The resource ID of the attached workspace
   - inverval                     (optional) How frequently service should do flow analytics in minutes. Defaults to 10
  
  DESCRIPTION
  type = object({
    name                = optional(string, "NetworkWatcher_northeurope")
    resource_group_name = optional(string, "NetworkWatcherRG")
    storage_account_id  = string
    retention_in_days   = optional(number, 7)
    traffic_analytics_workspace = optional(object({
      id          = string
      location    = optional(string, "northeurope")
      resource_id = optional(string, null)
      inverval    = optional(number, 10)
    }), null)
  })

  default = null
}
