# Plan-time tests for the module. The azurerm provider is mocked, so no credentials, no
# features block, and no cloud calls are needed:
#   terraform init -backend=false && terraform test

mock_provider "azurerm" {}

variables {
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-001"
  location          = "uksouth"
}

run "derives_reverse_zones_from_cidrs" {
  command = plan

  variables {
    reverse_dns_zone_cidrs = ["192.168.1.0/24", "10.0.0.0/16", "172.0.0.0/8"]
  }

  assert {
    condition     = contains(keys(azurerm_private_dns_zone.this), "1.168.192.in-addr.arpa")
    error_message = "A /24 should derive <third>.<second>.<first>.in-addr.arpa."
  }

  assert {
    condition     = contains(keys(azurerm_private_dns_zone.this), "0.10.in-addr.arpa")
    error_message = "A /16 should derive <second>.<first>.in-addr.arpa."
  }

  assert {
    condition     = contains(keys(azurerm_private_dns_zone.this), "172.in-addr.arpa")
    error_message = "A /8 should derive <first>.in-addr.arpa."
  }
}

run "creates_default_privatelink_zones" {
  command = plan

  variables {
    create_default_privatelink_zones = true
  }

  assert {
    condition     = contains(keys(azurerm_private_dns_zone.this), "privatelink.blob.core.windows.net")
    error_message = "The default privatelink set should include the blob zone."
  }

  assert {
    condition     = contains(keys(azurerm_private_dns_zone.this), "privatelink.vaultcore.azure.net")
    error_message = "The default privatelink set should include the key vault zone."
  }
}

run "renders_regional_zones_with_location" {
  command = plan

  variables {
    create_regional_privatelink_zones = true
    location                          = "uksouth"
  }

  assert {
    condition     = contains(keys(azurerm_private_dns_zone.this), "privatelink.uksouth.azmk8s.io")
    error_message = "Regional zones should be rendered with the location."
  }
}

run "links_every_zone_to_default_vnets" {
  command = plan

  variables {
    private_dns_zones = {
      "internal.example.com" = {}
      "10.in-addr.arpa"      = {}
    }
    default_vnet_links = {
      "hub" = {
        virtual_network_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet-hub"
      }
    }
  }

  assert {
    condition     = length(azurerm_private_dns_zone_virtual_network_link.this) == 2
    error_message = "default_vnet_links should produce one link per zone."
  }

  assert {
    condition     = azurerm_private_dns_zone_virtual_network_link.this["internal.example.com|hub"].registration_enabled == false
    error_message = "registration_enabled should default to false."
  }
}

run "derives_classless_dash_zones_for_non_octet_cidrs" {
  command = plan

  variables {
    reverse_dns_zone_cidrs = ["192.0.2.128/26", "10.114.0.0/22"]
  }

  assert {
    condition     = contains(keys(azurerm_private_dns_zone.this), "128-26.2.0.192.in-addr.arpa")
    error_message = "The Azure private reverse DNS documentation example (192.0.2.128/26) should derive 128-26.2.0.192.in-addr.arpa."
  }

  assert {
    condition     = contains(keys(azurerm_private_dns_zone.this), "0-22.114.10.in-addr.arpa")
    error_message = "A /22 should derive its exact classless dash-form zone."
  }
}

run "rejects_a_prefix_wider_than_slash_eight" {
  command = plan

  variables {
    reverse_dns_zone_cidrs = ["10.0.0.0/7"]
  }

  expect_failures = [var.reverse_dns_zone_cidrs]
}
