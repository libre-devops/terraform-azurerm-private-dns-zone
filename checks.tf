# check blocks run after every plan and apply and emit a warning (without blocking) when an
# invariant is violated. They are the place to enforce module-wide consistency.

# The module does nothing useful without at least one zone from some source.
check "creates_at_least_one_zone" {
  assert {
    condition     = length(local.all_zone_names) > 0
    error_message = "No zones would be created: set private_dns_zones, reverse_dns_zone_cidrs, or create_default_privatelink_zones."
  }
}

# Regional privatelink zones embed the region in their name, so they need a location to render.
check "regional_zones_have_location" {
  assert {
    condition     = !var.create_regional_privatelink_zones || var.location != null
    error_message = "create_regional_privatelink_zones is true but location is null; the regional zone names cannot be rendered."
  }
}

# A vnet may hold the auto-registration record set for only one zone. Warn if more than one link
# across all zones enables registration for the same vnet.
check "single_registration_per_vnet" {
  assert {
    condition     = length([for l in values(local.vnet_links) : l.virtual_network_id if l.registration_enabled]) == length(distinct([for l in values(local.vnet_links) : l.virtual_network_id if l.registration_enabled]))
    error_message = "More than one zone enables registration for the same virtual network; Azure allows auto-registration on only one zone per vnet."
  }
}
