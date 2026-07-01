output "private_dns_zone_ids" {
  description = "Map of zone name to zone id."
  value       = module.private_dns_zone.private_dns_zone_ids
}

output "private_dns_zone_ids_zipmap" {
  description = "Map of zone name to { name, id }."
  value       = module.private_dns_zone.private_dns_zone_ids_zipmap
}

output "private_dns_zone_names" {
  description = "The names of the zones created."
  value       = module.private_dns_zone.private_dns_zone_names
}

output "tags" {
  description = "The tags applied to the resources."
  value       = module.tags.tags
}

output "vnet_link_ids" {
  description = "Map of \"<zone>|<link>\" to vnet link id."
  value       = module.private_dns_zone.vnet_link_ids
}
