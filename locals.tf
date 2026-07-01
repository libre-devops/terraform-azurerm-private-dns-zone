locals {
  rg      = provider::azurerm::parse_resource_id(var.resource_group_id)
  rg_name = local.rg.resource_group_name

  # Reverse zones derived from IPv4 CIDRs. The variable validation guarantees a /8, /16 or /24, so
  # prefix/8 octets of the network reversed and suffixed with in-addr.arpa is the reverse zone name
  # (192.168.1.0/24 -> 1.168.192.in-addr.arpa).
  reverse_zone_names = [
    for c in var.reverse_dns_zone_cidrs :
    "${join(".", reverse(slice(split(".", split("/", c)[0]), 0, tonumber(split("/", c)[1]) / 8)))}.in-addr.arpa"
  ]

  # Region-specific privatelink zones, rendered with location when the caller opts in.
  regional_templates = [
    "privatelink.%s.azmk8s.io",
    "privatelink.%s.backup.windowsazure.com",
    "%s.privatelink.afs.azure.net",
    "privatelink.%s.kusto.windows.net",
  ]
  regional_zone_names = (var.create_regional_privatelink_zones && var.location != null) ? [for t in local.regional_templates : format(t, var.location)] : []

  privatelink_names = var.create_default_privatelink_zones ? tolist(var.privatelink_dns_zones) : []

  # Every zone name the module creates. Explicit private_dns_zones keys take precedence for config.
  all_zone_names = toset(concat(
    keys(var.private_dns_zones),
    local.reverse_zone_names,
    local.regional_zone_names,
    local.privatelink_names,
  ))

  # SOA record only comes from explicitly declared zones; generated zones use the Azure default SOA.
  zone_soa = { for z in local.all_zone_names : z => try(var.private_dns_zones[z].soa_record, null) }

  # Effective vnet links per zone: the shared default_vnet_links for every zone, with any per-zone
  # links (from private_dns_zones) merged on top.
  zone_links = {
    for z in local.all_zone_names : z => merge(
      var.default_vnet_links,
      contains(keys(var.private_dns_zones), z) ? var.private_dns_zones[z].vnet_links : {},
    )
  }

  # The link names per zone, derived only from the map KEYS of the inputs. keys() is known even when
  # the values (which can hold a virtual_network_id from a vnet created in the same apply) are not,
  # so the instance keys below stay known at plan time. A contains() guard is used instead of try():
  # try() returns a wholly-unknown value when its argument contains unknowns (it cannot prove at plan
  # whether the expression errors), which would poison keys() and make the for_each unknown. The
  # unknown-bearing config is looked up from zone_links only in the resource body, never in for_each.
  zone_link_names = {
    for z in local.all_zone_names : z => toset(concat(
      keys(var.default_vnet_links),
      contains(keys(var.private_dns_zones), z) ? keys(var.private_dns_zones[z].vnet_links) : [],
    ))
  }

  # Flatten to one instance per (zone, link), keyed "<zone>|<link>", values are known strings only.
  vnet_link_keys = {
    for item in flatten([
      for z, lks in local.zone_link_names : [
        for lk in lks : { key = "${z}|${lk}", zone_name = z, link_name = lk }
      ]
    ]) : item.key => { zone_name = item.zone_name, link_name = item.link_name }
  }

  # Vnet ids that have auto-registration enabled on some zone, for the single-registration check.
  registration_vnet_ids = flatten([
    for z, links in local.zone_links : [for lk, lv in links : lv.virtual_network_id if lv.registration_enabled]
  ])
}
