locals {
  #The below locals convert an IP address range into separate elements.  Take 10.0.2.0/24 for example:
  first_octet    = var.create_reverse_dns_zone == true && var.address_range != null ? element(split(".", element(var.address_range, 0)), 0) : null                        # Gets the first octet of range, so for example, 10
  second_octet   = var.create_reverse_dns_zone == true && var.address_range != null ? element(split(".", element(var.address_range, 0)), 1) : null                        # Gets the second octet of range, so for example, 0
  third_octet    = var.create_reverse_dns_zone == true && var.address_range != null ? element(split(".", element(var.address_range, 0)), 2) : null                        # Gets the third octet of range, so for example, 2
  fourth_element = var.create_reverse_dns_zone == true && var.address_range != null ? element(split(".", element(var.address_range, 0)), 3) : null                        # Gets the forth element of range, so for example, 0/24
  fourth_octet   = var.create_reverse_dns_zone == true && var.address_range != null && local.fourth_element != null ? element(split("/", local.fourth_element), 0) : null # Gets the fourth element of range, so for example, 0
  cidr_range     = var.create_reverse_dns_zone == true && var.address_range != null && local.fourth_element != null ? element(split("/", local.fourth_element), 1) : null # Gets the the cidr portion of the range, so for example, 24

  # Reconstructs the name using above elements to create, for example, 24-0.2.0.10.in-addr.arpa
  reverse_zone_name = var.create_reverse_dns_zone == true && var.address_range != null ? format("%d-%d.%d.%d.%d.in-addr.arpa", local.cidr_range, local.fourth_octet, local.third_octet, local.second_octet, local.first_octet) : null
}

resource "azurerm_private_dns_zone" "reverse_dns_zone" {
  for_each = var.create_reverse_dns_zone == true && var.address_range != null ? toset(var.address_range) : []

  name                = local.reverse_zone_name
  resource_group_name = var.rg_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "reverse_dns_zone_link" {
  for_each              = try(var.link_to_vnet, true) == true && var.create_reverse_dns_zone == true && var.address_range != null ? toset(var.address_range) : []
  name                  = var.vnet_link_name == null ? "pdnsz-${replace(azurerm_private_dns_zone.reverse_dns_zone[each.key].name, ".", "")}" : try(var.vnet_link_name, null)
  resource_group_name   = try(var.rg_name, null)
  private_dns_zone_name = azurerm_private_dns_zone.reverse_dns_zone[each.key].name
  virtual_network_id    = try(var.vnet_id, null)
  tags                  = try(var.tags, null)
}
