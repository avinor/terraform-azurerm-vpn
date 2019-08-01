output "gateway_id" {
  description = "The ID of the virtual network gateway."
  value       = azurerm_virtual_network_gateway.gw.id
}

output "fqdns" {
  description = "List of the fqdn for gateway. Will return 2 for active_active mode and 1 otherwise"
  value       = flatten([[azurerm_public_ip.gw.fqdn], var.active_active ? [azurerm_public_ip.gw_aa[0].fqdn] : []])
}