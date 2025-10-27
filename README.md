<!-- BEGIN_TF_DOCS -->
# Azure Virtual Network Terraform module

Terraform module which creates Azure Virtual Network resources on Azure.

Supported Azure services:

* [Azure Virtual network](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)
* [Azure Network Security Group](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
* [Subnet Delegation](https://learn.microsoft.com/en-us/azure/virtual-network/subnet-delegation-overview)
* [User Defined Route](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-udr-overview#user-defined)
* [Virtual network peering](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview)
* [NSG Flow Logs](https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-overview)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.6 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.70.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.70.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.explicit_azlb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.explicit_inbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.explicit_outbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_watcher_flow_log.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher_flow_log) | resource |
| [azurerm_route.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route) | resource |
| [azurerm_route_table.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_subnet_route_table_association.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_dns_servers.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_dns_servers) | resource |
| [azurerm_virtual_network_peering.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | A list of the Virtual Network address space(s). This parameter is required | `list(string)` | n/a | yes |
| <a name="input_bgp_community"></a> [bgp\_community](#input\_bgp\_community) | The BGP community attribute in format <as-number>:<community-value> | `string` | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | A list of DNS Server IP(s). This parameter is optional | `list(string)` | `null` | no |
| <a name="input_flow_timeout_in_minutes"></a> [flow\_timeout\_in\_minutes](#input\_flow\_timeout\_in\_minutes) | The flow timeout in minutes for the Virtual Network, which is used to enable connection tracking for intra-VM flows. Possible values are between 4 and 30 minutes | `number` | `null` | no |
| <a name="input_local_peering"></a> [local\_peering](#input\_local\_peering) | A list of vNet ID(s) to create peering on this vnet, the peering will be created only on local vNet. This parameter is optional<br/>  This can be usefull if you need to establish a peering between this and other vnets but have no controll on remote vNet<br/>   - vnet\_id:                       (required) The full Azure resource ID of the remote virtual network<br/>   - peering\_name:                  (optional) If not defined, the vnet name will be used in the peering name<br/>   - allow\_virtual\_network\_access:  (optional) Controls if the VMs in the remote virtual network can access VMs in the local virtual network. Defaults to true<br/>   - allow\_forwarded\_traffic:       (optional) Controls if forwarded traffic from VMs in the remote virtual network is allowed. Defaults to false<br/>   - allow\_gateway\_transit:         (optional) Controls gatewayLinks can be used in the remote virtual network’s link to the local virtual network. Defaults to false<br/>   - use\_remote\_gateways:           (optional) Controls if remote gateways can be used on the local virtual network. Defaults to false | <pre>list(object({<br/>    vnet_id                      = string<br/>    peering_name                 = optional(string, null)<br/>    allow_virtual_network_access = optional(bool, true)<br/>    allow_forwarded_traffic      = optional(bool, false)<br/>    allow_gateway_transit        = optional(bool, false)<br/>    use_remote_gateways          = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | The region where the Virtual Network will be created. This parameter is required | `string` | `"northeurope"` | no |
| <a name="input_name"></a> [name](#input\_name) | Virtual network name. This parameter is required | `string` | n/a | yes |
| <a name="input_network_flow_log"></a> [network\_flow\_log](#input\_network\_flow\_log) | Network flow log parameters. This parameter is optional<br/>   - name                         (optional) The name of the Network Watcher Flow Log. Defaults to "NetworkWatcher\_northeurope"<br/>   - resource\_group\_name          (optional) The name of the resource group in which the Network Watcher was deployed. Defaults to "NetworkWatcherRG"<br/>   - storage\_account\_id           (required) The ID of the Storage Account where flow logs are stored<br/>   - retention\_in\_days            (optional) The number of days to retain flow log records. Defaults to 7<br/>   - traffic\_analytics\_workspace  (optional) A block as defined bellow<br/>   - id                           (required) The resource GUID of the attached workspace <br/>   - location                     (optional) The location of the attached workspace. Defaults to "North Europe"<br/>   - resource\_id                  (required) The resource ID of the attached workspace<br/>   - inverval                     (optional) How frequently service should do flow analytics in minutes. Defaults to 10 | <pre>object({<br/>    name                = optional(string, "NetworkWatcher_northeurope")<br/>    resource_group_name = optional(string, "NetworkWatcherRG")<br/>    storage_account_id  = string<br/>    retention_in_days   = optional(number, 7)<br/>    traffic_analytics_workspace = optional(object({<br/>      id          = string<br/>      location    = optional(string, "northeurope")<br/>      resource_id = optional(string, null)<br/>      inverval    = optional(number, 10)<br/>    }), null)<br/>  })</pre> | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which the resources will be created. This parameter is required | `string` | n/a | yes |
| <a name="input_route_table"></a> [route\_table](#input\_route\_table) | A map of route tables. This parameter is optional<br/>   - bgp\_route\_propagation\_enabled  (optional) Boolean flag which controls propagation of routes learned by BGP on that route table. Defaults to false<br/>   - routes                         (optional) A block as defined bellow<br/>    - address\_prefix                (required) The destination to which the route applies. Can be CIDR (such as 10.1.0.0/16) or Azure Service Tag (such as ApiManagement, AzureBackup or AzureMonitor) format<br/>    - next\_hop\_type                 (required) The type of Azure hop the packet should be sent to. Possible values are VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance and None<br/>    - next\_hop\_in\_ip\_address        (optional) Contains the IP address packets should be forwarded to. Next hop values are only allowed in routes where the next hop type is VirtualAppliance. Defaults to null | <pre>map(object({<br/>    bgp_route_propagation_enabled = optional(bool, false)<br/>    routes = map(object({<br/>      address_prefix         = string<br/>      next_hop_type          = string<br/>      next_hop_in_ip_address = optional(string, null)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A map of Subnets. This parameter is required<br/>  - address\_prefixes                              (required) The address prefixes to use for the subnet<br/>  - route\_table\_name                              (optional) The route table name to be associated to this subnet. Defaults to null<br/>  - service\_endpoints                             (optional) The list of Service endpoints to associate with the subnet. Defaults to null<br/>  - nsg\_create\_default                            (optional) Define if a NSG should be created for this subnet. Defaults to true<br/>  - nsg\_create\_explicit\_in\_rule                   (optional) Define if a default explicit deny inbound rule should be created. Defaults to true<br/>  - nsg\_create\_explicit\_out\_rule                  (optional) Define if a default explicit deny outbound rule should be created. Defaults to false<br/>  - service\_endpoint\_policy\_ids                   (optional) The list of IDs of Service Endpoint Policies to associate with the subnet. Defaults to null<br/>  - service\_delegation                            (optional) A block as defined bellow<br/>    - name                                        (required) The name of service to delegate to<br/>    - actions                                     (optional) A list of Actions which should be delegated. This list is specific to the service to delegate to<br/>  - private\_endpoint\_network\_policies             (optional) Enable or Disable network policies for the private endpoint on the subnet. Possible values are Disabled, Enabled, NetworkSecurityGroupEnabled and RouteTableEnabled. Defaults to Enabled<br/>  - private\_link\_service\_network\_policies\_enabled (optional) Enable or Disable network policies for the private link service on the subnet. Defaults to true<br/>  - nsg\_rules:                                    (optional) A block as defined bellow<br/>    - description                                 (optional) A description for this rule. Restricted to 140 characters<br/>    - protocol                                    (optional) Network protocol this rule applies to. Possible values include Tcp, Udp, Icmp, Esp, Ah or '*'. Defaults to TCP<br/>    - priority                                    (required) Specifies the priority of the rule. The value can be between 100 and 4096<br/>    - direction                                   (optional) The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are Inbound and Outbound. Defaults to "Inbound"<br/>    - access                                      (optional) Specifies whether network traffic is allowed or denied. Possible values are Allow and Deny. Defaults to Allow<br/>    - source\_port\_range                           (optional) Source Port or Range. Integer or range between 0 and 65535 or * to match any. Defaults to '*'<br/>    - source\_port\_ranges                          (optional) List of source ports or port ranges<br/>    - destination\_port\_range                      (optional) Destination Port or Range. Integer or range between 0 and 65535 or * to match any. This is required if destination\_port\_ranges is not specified<br/>    - destination\_port\_ranges                     (optional) List of destination ports or port ranges. This is required if destination\_port\_range is not specified<br/>    - source\_address\_prefix                       (optional) CIDR or source IP range or * to match any IP. Tags such as VirtualNetwork, AzureLoadBalancer and Internet can also be used. This is required if source\_address\_prefixes or source\_application\_security\_group\_ids is not specified<br/>    - source\_address\_prefixes                     (optional) List of source address prefixes. Tags may not be used. This is required if source\_address\_prefix or source\_application\_security\_group\_ids is not specified<br/>    - destination\_address\_prefix                  (optional) CIDR or destination IP range or * to match any IP. Tags such as VirtualNetwork, AzureLoadBalancer and Internet can also be used. Besides, it also supports all available Service Tags like ‘Sql.WestEurope‘, ‘Storage.EastUS‘, etc. This is required if destination\_address\_prefixes or destination\_application\_security\_group\_ids is not specified<br/>    - destination\_address\_prefixes                (optional) List of destination address prefixes. Tags may not be used. This is required if destination\_address\_prefix or destination\_application\_security\_group\_ids is not specified<br/>    - source\_application\_security\_group\_ids       (optional) A List of source Application Security Group IDs<br/>    - destination\_application\_security\_group\_ids  (optional) A List of destination Application Security Group IDs | <pre>map(object({<br/>    address_prefixes             = list(string),<br/>    route_table_name             = optional(string, null)<br/>    service_endpoints            = optional(list(string), null)<br/>    nsg_create_default           = optional(bool, true)<br/>    nsg_create_explicit_in_rule  = optional(bool, true)<br/>    nsg_create_explicit_out_rule = optional(bool, false)<br/>    service_endpoint_policy_ids  = optional(list(string), null)<br/>    service_delegation = optional(object({<br/>      name    = string<br/>      actions = optional(list(string), null)<br/>    }), null)<br/>    private_endpoint_network_policies             = optional(string, "Enabled")<br/>    private_link_service_network_policies_enabled = optional(bool, true)<br/>    nsg_rules = optional(map(object({<br/>      description                                = optional(string),<br/>      protocol                                   = optional(string, "Tcp"),<br/>      priority                                   = number,<br/>      direction                                  = optional(string, "Inbound"),<br/>      access                                     = optional(string, "Allow"),<br/>      source_port_range                          = optional(string, "*"),<br/>      source_port_ranges                         = optional(list(string), null),<br/>      destination_port_range                     = optional(string, null),<br/>      destination_port_ranges                    = optional(list(string), null),<br/>      source_address_prefix                      = optional(string, null),<br/>      source_address_prefixes                    = optional(list(string), null),<br/>      destination_address_prefix                 = optional(string, null),<br/>      destination_address_prefixes               = optional(list(string), null),<br/>      source_application_security_group_ids      = optional(list(string), null),<br/>      destination_application_security_group_ids = optional(list(string), null)<br/>    })), null)<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to resources. | `map(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nsg_ids"></a> [nsg\_ids](#output\_nsg\_ids) | n/a |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | n/a |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | n/a |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | n/a |

## Examples
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
More examples in ./examples folder
<!-- END_TF_DOCS -->