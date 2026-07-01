output "private_dns_zone_ids" {
  description = "Map of zone name to zone id."
  value       = { for k, z in azurerm_private_dns_zone.this : k => z.id }
}

output "private_dns_zone_ids_zipmap" {
  description = "Map of zone name to { name, id }, for easy composition with the private-endpoint module."
  value       = { for k, z in azurerm_private_dns_zone.this : k => { name = z.name, id = z.id } }
}

output "private_dns_zone_names" {
  description = "The names of the zones created."
  value       = sort(keys(azurerm_private_dns_zone.this))
}

output "private_dns_zones" {
  description = "The full azurerm_private_dns_zone resources, keyed by zone name."
  value       = azurerm_private_dns_zone.this
}

output "vnet_link_ids" {
  description = "Map of \"<zone>|<link>\" to vnet link id."
  value       = { for k, l in azurerm_private_dns_zone_virtual_network_link.this : k => l.id }
}

output "vnet_links" {
  description = "The full azurerm_private_dns_zone_virtual_network_link resources, keyed by \"<zone>|<link>\"."
  value       = azurerm_private_dns_zone_virtual_network_link.this
}
