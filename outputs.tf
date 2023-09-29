output "vnet_name" {
  value = azurerm_virtual_network.default.id
}

output "vnet_id" {
  value = azurerm_virtual_network.default.id
}

output "subnet_ids" {
  value = { for key, value in azurerm_subnet.default : value.name => value.id }
}

output "nsg_ids" {
  value = { for key, value in azurerm_network_security_group.default : value.name => value.id }
}
