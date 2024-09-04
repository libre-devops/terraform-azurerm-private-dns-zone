resource "azurerm_private_dns_zone" "private_dns_zone" {
  for_each            = var.create_private_dns_zone == true ? toset(["true"]) : toset([])
  name                = try(var.private_dns_zone_name, null)
  resource_group_name = try(var.rg_name, null)
  tags                = try(var.tags, null)

  dynamic "soa_record" {
    for_each = try(var.soa_record, null) != null ? [1] : []
    content {
      email        = try(var.soa_record["email"], null)
      expire_time  = try(var.soa_record["expire_time"], null)
      minimum_ttl  = try(var.soa_record["minimum_ttl"], null)
      refresh_time = try(var.soa_record["refresh_time"], null)
      retry_time   = try(var.soa_record["retry_time"], null)
      ttl          = try(var.soa_record["ttl"], null)
      tags         = try(var.soa_record["tags"], var.tags, null)
    }
  }
}

resource "azurerm_private_dns_zone" "privatelink_dns_zones" {
  for_each = var.create_default_privatelink_zones == true ? {
    for idx, value in var.privatelink_dns_zones : value.zone_name => merge(value, { index = idx })
  } : {}
  name                = each.key
  resource_group_name = try(var.rg_name, null)
  tags                = try(var.tags, null)

  dynamic "soa_record" {
    for_each = try(var.soa_record, null) != null ? [1] : []
    content {
      email        = try(var.soa_record["email"], null)
      expire_time  = try(var.soa_record["expire_time"], null)
      minimum_ttl  = try(var.soa_record["minimum_ttl"], null)
      refresh_time = try(var.soa_record["refresh_time"], null)
      retry_time   = try(var.soa_record["retry_time"], null)
      ttl          = try(var.soa_record["ttl"], null)
      tags         = try(var.soa_record["tags"], var.tags, null)
    }
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_link" {
  for_each = try(var.link_to_vnet, true) == true && var.create_private_dns_zone == true ? toset([
    "true"
  ]) : toset([])
  name                  = var.vnet_link_name == null ? "${lower(replace(azurerm_private_dns_zone.private_dns_zone[each.key].name, ".", "-"))}-link-to-${local.vnet_name}" : try(var.vnet_link_name, null)
  resource_group_name   = try(var.rg_name, null)
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone[each.key].name
  virtual_network_id    = try(var.vnet_id, null)
  tags                  = try(var.tags, null)
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_link_hub" {
  for_each = try(var.link_to_vnet, true) == true && var.create_private_dns_zone == true && var.attempt_private_dns_zone_link_to_hub == true ? toset([
    "true"
  ]) : toset([])
  name                  = var.vnet_link_name == null ? "${lower(replace(azurerm_private_dns_zone.private_dns_zone[each.key].name, ".", "-"))}-link-to-${local.hub_vnet_name}" : try(var.vnet_link_name, null)
  resource_group_name   = try(var.rg_name, null)
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone[each.key].name
  virtual_network_id    = try(var.hub_vnet_id, null)
  tags                  = try(var.tags, null)
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_dns_zone_link" {
  for_each = var.link_to_vnet == true && var.create_default_privatelink_zones == true ? {
    for idx, value in var.privatelink_dns_zones : value.zone_name => merge(value, { index = idx })
  } : {}
  name                  = var.vnet_link_name == null ? "${lower(replace(azurerm_private_dns_zone.privatelink_dns_zones[each.key].name, ".", "-"))}-link-to-${local.vnet_name}" : try(var.vnet_link_name, null)
  resource_group_name   = try(var.rg_name, null)
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_dns_zones[each.key].name
  virtual_network_id    = try(var.vnet_id, null)
  tags                  = try(var.tags, null)
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_dns_zone_link_hub" {
  for_each = try(var.link_to_vnet, true) == true && var.create_default_privatelink_zones == true && var.attempt_privatelink_dns_zone_link_to_hub == true ? {
    for idx, value in var.privatelink_dns_zones : value.zone_name => merge(value, { index = idx })
  } : {}
  name                  = var.vnet_link_name == null ? "${lower(replace(azurerm_private_dns_zone.privatelink_dns_zones[each.key].name, ".", "-"))}-link-to-${local.hub_vnet_name}" : try(var.vnet_link_name, null)
  resource_group_name   = try(var.rg_name, null)
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_dns_zones[each.key].name
  virtual_network_id    = try(var.hub_vnet_id, null)
  tags                  = try(var.tags, null)
}

