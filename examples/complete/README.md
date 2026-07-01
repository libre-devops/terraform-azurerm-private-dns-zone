<!--
  Header for the complete example README. Edit this file, then run `just docs`
  (or ./Sort-LdoTerraform.ps1 -IncludeExamples) to regenerate the section between the markers.
  The example's main.tf is embedded into the README automatically (see .terraform-docs.yml).
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="200">
    </picture>
  </a>
</div>

# Complete example

Exercises the fuller surface of this module. The environment comes from the Terraform workspace
(`terraform.workspace`), not a variable. Run it with `just e2e complete`, which applies the stack
then always destroys it.

[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)

<!-- BEGIN_TF_DOCS -->
## Example configuration

```hcl
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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [network](#module\_network) | libre-devops/network/azurerm | ~> 4.0 |
| <a name="module_network_spoke"></a> [network\_spoke](#module\_network\_spoke) | libre-devops/network/azurerm | ~> 4.0 |
| <a name="module_private_dns_zone"></a> [private\_dns\_zone](#module\_private\_dns\_zone) | ../../ | n/a |
| <a name="module_rg"></a> [rg](#module\_rg) | libre-devops/rg/azurerm | ~> 4.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | libre-devops/tags/azurerm | ~> 4.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployed_branch"></a> [deployed\_branch](#input\_deployed\_branch) | Git branch the deployment came from. Auto-filled in CI from TF\_VAR\_deployed\_branch. | `string` | `""` | no |
| <a name="input_deployed_repo"></a> [deployed\_repo](#input\_deployed\_repo) | Repository URL the deployment came from. Auto-filled in CI from TF\_VAR\_deployed\_repo. | `string` | `""` | no |
| <a name="input_loc"></a> [loc](#input\_loc) | Outfix: short Azure region code used in resource names (for example uks). | `string` | `"uks"` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | Map of short region codes to Azure region slugs. | `map(string)` | <pre>{<br/>  "eus": "eastus",<br/>  "euw": "westeurope",<br/>  "uks": "uksouth",<br/>  "ukw": "ukwest"<br/>}</pre> | no |
| <a name="input_short"></a> [short](#input\_short) | Infix: short product code used in resource names. | `string` | `"ldo"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#output\_private\_dns\_zone\_ids) | Map of zone name to zone id. |
| <a name="output_private_dns_zone_ids_zipmap"></a> [private\_dns\_zone\_ids\_zipmap](#output\_private\_dns\_zone\_ids\_zipmap) | Map of zone name to { name, id }. |
| <a name="output_private_dns_zone_names"></a> [private\_dns\_zone\_names](#output\_private\_dns\_zone\_names) | The names of the zones created. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags applied to the resources. |
| <a name="output_vnet_link_ids"></a> [vnet\_link\_ids](#output\_vnet\_link\_ids) | Map of "<zone>\|<link>" to vnet link id. |
<!-- END_TF_DOCS -->
