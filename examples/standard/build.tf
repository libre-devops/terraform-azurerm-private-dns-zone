module "rg" {
  source = "registry.terraform.io/libre-devops/rg/azurerm"

  rg_name  = "rg-${var.short}-${var.loc}-${terraform.workspace}-build" // rg-ldo-euw-dev-build
  location = local.location                                            // compares var.loc with the var.regions var to match a long-hand name, in this case, "euw", so "westeurope"
  tags     = local.tags

  #  lock_level = "CanNotDelete" // Do not set this value to skip lock
}

module "network" {
  source = "registry.terraform.io/libre-devops/network/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  vnet_name     = "vnet-${var.short}-${var.loc}-${terraform.workspace}-01" // vnet-ldo-euw-dev-01
  vnet_location = module.network.vnet_location

  address_space = ["10.0.0.0/16"]
  subnet_prefixes = [
    "10.0.0.0/24",
    "10.0.1.0/24",
  ]

  subnet_names = [
    "sn1-${module.network.vnet_name}",
    "sn2-${module.network.vnet_name}",
  ]

  subnet_service_endpoints = {
    "sn1-${module.network.vnet_name}" = ["Microsoft.Storage", "Microsoft.Keyvault", "Microsoft.Sql", "Microsoft.Web", "Microsoft.AzureActiveDirectory"],
    "sn2-${module.network.vnet_name}" = ["Microsoft.Storage", "Microsoft.Keyvault", "Microsoft.Sql", "Microsoft.Web", "Microsoft.AzureActiveDirectory"]
  }

  subnet_delegation = {
    "sn1-${module.network.vnet_name}" = {
      "Microsoft.Web/serverFarms" = {
        service_name    = "Microsoft.Web/serverFarms"
        service_actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
}


module "dns" {
  source                           = "registry.terraform.io/libre-devops/private-dns-zone/azurerm"
  location                         = module.rg.rg_location
  rg_name                          = module.rg.rg_name
  create_default_privatelink_zones = true
  link_to_vnet                     = true
  vnet_id                          = module.network.vnet_id
}
