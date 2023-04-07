output "dns_number_of_record_sets" {
  description = "The max number of virtual network links with registration"
  value       = var.create_default_privatelink_zones ? values(azurerm_private_dns_zone.privatelink_dns_zones)[*].number_of_record_sets : values(azurerm_private_dns_zone.private_dns_zone)[*].number_of_record_sets
}

output "dns_zone_id" {
  description = "The dns zone ids"
  value       = var.create_default_privatelink_zones ? values(azurerm_private_dns_zone.privatelink_dns_zones)[*].id : values(azurerm_private_dns_zone.private_dns_zone)[*].id
}

output "dns_zone_max_number_of_record_sets" {
  description = "The max number of record sets"
  value       = var.create_default_privatelink_zones ? values(azurerm_private_dns_zone.privatelink_dns_zones)[*].max_number_of_record_sets : values(azurerm_private_dns_zone.private_dns_zone)[*].max_number_of_record_sets
}

output "dns_zone_max_number_of_virtual_network_links" {
  description = "The dns max number of virtual network links"
  value       = var.create_default_privatelink_zones ? values(azurerm_private_dns_zone.privatelink_dns_zones)[*].max_number_of_virtual_network_links : values(azurerm_private_dns_zone.private_dns_zone)[*].max_number_of_virtual_network_links
}

output "dns_zone_max_number_of_virtual_network_links_with_registration" {
  description = "The max number of virtual network links with registration"
  value       = var.create_default_privatelink_zones ? values(azurerm_private_dns_zone.privatelink_dns_zones)[*].max_number_of_virtual_network_links_with_registration : values(azurerm_private_dns_zone.private_dns_zone)[*].max_number_of_virtual_network_links_with_registration
}

output "dns_zone_name" {
  description = "The dns zone name"
  value       = var.create_default_privatelink_zones ? values(azurerm_private_dns_zone.privatelink_dns_zones)[*].name : values(azurerm_private_dns_zone.private_dns_zone)[*].name
}

output "vnet_link_id" {
  description = "The vnet link ids"
  value       = var.create_default_privatelink_zones ? values(azurerm_private_dns_zone_virtual_network_link.privatelink_dns_zone_link)[*].id : values(azurerm_private_dns_zone_virtual_network_link.private_dns_zone_link)[*].id
}
