output "private_dns_zone_ids" {
  description = "Map of zone name to zone id."
  value       = module.private_dns_zone.private_dns_zone_ids
}

output "private_dns_zone_names" {
  description = "The names of the zones created."
  value       = module.private_dns_zone.private_dns_zone_names
}
