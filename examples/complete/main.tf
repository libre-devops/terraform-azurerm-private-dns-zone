locals {
  location        = lookup(var.regions, var.loc, "uksouth")
  rg_name         = "rg-${var.short}-${var.loc}-${terraform.workspace}-002"
  vnet_name       = "vnet-${var.short}-${var.loc}-${terraform.workspace}-002"
  vnet_spoke_name = "vnet-${var.short}-${var.loc}-${terraform.workspace}-spoke-002"
}

module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  environment     = "prd"
  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
  additional_tags = { Application = "terraform-azurerm-private-dns-zone" }
}

module "rg" {
  source  = "libre-devops/rg/azurerm"
  version = "~> 4.0"

  resource_groups = [{ name = local.rg_name, location = local.location, tags = module.tags.tags }]
}

module "network" {
  source  = "libre-devops/network/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  vnet_name     = local.vnet_name
  address_space = ["10.2.0.0/16"]
  subnets       = {}
}

# A second vnet, so the forward zone can enable auto-registration against it while the hub link on
# every zone stays registration-free (a vnet may auto-register in only one zone).
module "network_spoke" {
  source  = "libre-devops/network/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  vnet_name     = local.vnet_spoke_name
  address_space = ["10.3.0.0/16"]
  subnets       = {}
}

# Complete call: exercise every source at once.
# - an explicit forward zone with a custom SOA and its own vnet link (registration enabled);
# - reverse zones derived from two CIDRs (/24 and /16);
# - the canonical privatelink set (overridden here to a short list so the self-test stays quick);
# - the regional privatelink zones, rendered with location;
# - a default vnet link applied to every zone above.
module "private_dns_zone" {
  source = "../../"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  private_dns_zones = {
    "internal.example.com" = {
      soa_record = {
        email = "hostmaster.internal.example.com"
        ttl   = 3600
      }
      vnet_links = {
        "spoke-registration" = {
          virtual_network_id   = module.network_spoke.vnet_id
          registration_enabled = true
        }
      }
    }
  }

  reverse_dns_zone_cidrs = ["192.168.1.0/24", "10.2.0.0/16"]

  create_default_privatelink_zones = true
  privatelink_dns_zones = [
    "privatelink.blob.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.file.core.windows.net",
  ]

  create_regional_privatelink_zones = true

  default_vnet_links = {
    "hub" = {
      virtual_network_id = module.network.vnet_id
    }
  }
}
