# Private DNS zones from three sources, unified into one set (local.all_zone_names): zones you name
# explicitly (forward, or reverse by name), reverse zones derived from CIDRs, and the canonical
# Azure Private Link zone set (global, plus optional regional). Private DNS zones are global, so
# there is no location argument.
resource "azurerm_private_dns_zone" "this" {
  for_each = local.all_zone_names

  resource_group_name = local.rg_name
  tags                = var.tags
  name                = each.value

  dynamic "soa_record" {
    for_each = local.zone_soa[each.value] != null ? [local.zone_soa[each.value]] : []
    content {
      email        = soa_record.value.email
      expire_time  = soa_record.value.expire_time
      minimum_ttl  = soa_record.value.minimum_ttl
      refresh_time = soa_record.value.refresh_time
      retry_time   = soa_record.value.retry_time
      ttl          = soa_record.value.ttl
      tags         = coalesce(soa_record.value.tags, var.tags)
    }
  }
}

# Vnet links: the shared default_vnet_links applied to every zone, plus any per-zone links, flattened
# to one resource per (zone, link).
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = local.vnet_links

  resource_group_name   = local.rg_name
  tags                  = coalesce(each.value.tags, var.tags)
  name                  = each.value.link_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.value.zone_name].name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = each.value.registration_enabled
  resolution_policy     = each.value.resolution_policy
}
