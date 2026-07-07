<!--
  Keep the title and badges OUTSIDE the centered <div>: the Terraform Registry's markdown renderer
  does not parse markdown inside an HTML block, so a # heading or [![badge]] in the div renders as
  literal text on the registry. Only the logo (HTML) goes in the div.
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="300">
    </picture>
  </a>
</div>

# Terraform Azure Private DNS Zone

Create Azure private DNS zones (forward, reverse, and the full Azure Private Link set) and link them to vnets.

[![CI](https://github.com/libre-devops/terraform-azurerm-private-dns-zone/actions/workflows/ci.yml/badge.svg)](https://github.com/libre-devops/terraform-azurerm-private-dns-zone/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/libre-devops/terraform-azurerm-private-dns-zone?sort=semver&label=release)](https://github.com/libre-devops/terraform-azurerm-private-dns-zone/releases/latest)
[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)
[![License](https://img.shields.io/github/license/libre-devops/terraform-azurerm-private-dns-zone)](./LICENSE)

---

## Overview

One module for every private DNS zone shape, unified into a single set and a single vnet-link pass.
Private DNS zones are global, so the module takes only the resource group id (no location, except to
render the regional privatelink zone names).

Zones come from four sources, all optional and combined:

- **Forward zones** you name in `private_dns_zones` (with an optional custom `soa_record`).
- **Reverse zones** two ways: named directly in `private_dns_zones` (including IPv6 `ip6.arpa`), or
  derived from IPv4 CIDRs in `reverse_dns_zone_cidrs` (`192.168.1.0/24` -> `1.168.192.in-addr.arpa`;
  /8, /16 and /24 boundaries).
- **The canonical Azure Private Link set** via `create_default_privatelink_zones` (60+ global zones,
  overridable through `privatelink_dns_zones`), plus the region-specific ones (AKS, backup, file sync,
  Kusto) via `create_regional_privatelink_zones` and `location`.

Vnet linking is unified: `default_vnet_links` is applied to **every** zone the module creates (the
usual "link all privatelink zones to the hub" case), and per-zone `vnet_links` are merged on top for
anything bespoke (for example enabling auto-registration on one forward zone). `check` blocks warn if
regional zones are requested without a location, or if two zones would auto-register the same vnet.

Pairs with the [private-endpoint](https://github.com/libre-devops/terraform-azurerm-private-endpoint)
module: feed `private_dns_zone_ids_zipmap` (or `private_dns_zone_ids`) into its DNS zone group.

## Usage

```hcl
module "private_dns_zone" {
  source  = "libre-devops/private-dns-zone/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids["rg-dns-hub-prd-001"]
  location          = "uksouth"
  tags              = module.tags.tags

  # Every canonical privatelink zone, all linked to the hub vnet.
  create_default_privatelink_zones = true
  default_vnet_links = {
    "hub" = { virtual_network_id = module.network.vnet_id }
  }

  # A forward zone and a reverse zone for the spoke range.
  private_dns_zones      = { "internal.example.com" = {} }
  reverse_dns_zone_cidrs = ["10.0.0.0/16"]
}
```

## Examples

- [`examples/minimal`](./examples/minimal) - a single forward zone, no links.
- [`examples/complete`](./examples/complete) - a forward zone with a custom SOA and registration link,
  CIDR-derived reverse zones, the privatelink set (trimmed for speed), regional zones, and a default
  hub link on every zone.

## Developing

Local work needs **PowerShell 7+** and **[`just`](https://github.com/casey/just)**, because the recipes
wrap the [LibreDevOpsHelpers](https://www.powershellgallery.com/packages/LibreDevOpsHelpers)
PowerShell module (the same engine the `libre-devops/terraform-azure` action runs in CI). Install
just with `brew install just`, or `uv tool add rust-just` then `uv run just <recipe>`.

Run `just` to list recipes: `just update-ldo-pwsh`, `just validate`, `just scan` (Trivy only),
`just pwsh-analyze`, `just plan`, `just apply`, `just destroy`, `just e2e` (apply then always destroy),
`just test`, and `just docs`. Releasing is also `just`:
`just increment-release [patch|minor|major]` bumps, tags, and publishes a GitHub release, and the
Terraform Registry picks up the tag.

## Security scan exceptions

This module is scanned with [Trivy](https://github.com/aquasecurity/trivy); HIGH and CRITICAL
findings fail the build. There are currently **no exceptions**: private DNS zones and vnet links
carry no security posture Trivy evaluates. Waivers, if ever needed, live in
[`.trivyignore.yaml`](./.trivyignore.yaml) and are mirrored in a table here.

## Reference

The Requirements, Providers, Inputs, Outputs, and Resources below are generated by `terraform-docs`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_default_privatelink_zones"></a> [create\_default\_privatelink\_zones](#input\_create\_default\_privatelink\_zones) | Create the full canonical set of global Azure Private Link DNS zones (privatelink\_dns\_zones). Off by default. | `bool` | `false` | no |
| <a name="input_create_regional_privatelink_zones"></a> [create\_regional\_privatelink\_zones](#input\_create\_regional\_privatelink\_zones) | Create the region-specific privatelink zones (AKS, backup, file sync, Kusto). Requires location. Off by default. | `bool` | `false` | no |
| <a name="input_default_vnet_links"></a> [default\_vnet\_links](#input\_default\_vnet\_links) | Vnet links added to every zone this module creates, keyed by link name. Merged with any per-zone vnet\_links. | <pre>map(object({<br/>    virtual_network_id   = string<br/>    registration_enabled = optional(bool, false)<br/>    resolution_policy    = optional(string)<br/>    tags                 = optional(map(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region used only to render the regional privatelink zone names (for example uksouth in privatelink.uksouth.azmk8s.io). Required when create\_regional\_privatelink\_zones is true; otherwise ignored. | `string` | `null` | no |
| <a name="input_private_dns_zones"></a> [private\_dns\_zones](#input\_private\_dns\_zones) | Map of private DNS zones to create, keyed by zone name (for example "internal.example.com" or "1.168.192.in-addr.arpa"). | <pre>map(object({<br/>    soa_record = optional(object({<br/>      email        = string<br/>      expire_time  = optional(number)<br/>      minimum_ttl  = optional(number)<br/>      refresh_time = optional(number)<br/>      retry_time   = optional(number)<br/>      ttl          = optional(number)<br/>      tags         = optional(map(string))<br/>    }))<br/>    vnet_links = optional(map(object({<br/>      virtual_network_id   = string<br/>      registration_enabled = optional(bool, false)<br/>      resolution_policy    = optional(string)<br/>      tags                 = optional(map(string))<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_privatelink_dns_zones"></a> [privatelink\_dns\_zones](#input\_privatelink\_dns\_zones) | The set of global Azure Private Link zone names created when create\_default\_privatelink\_zones is true. Defaults to the canonical global set; override to trim or extend it. | `set(string)` | <pre>[<br/>  "privatelink.azure-automation.net",<br/>  "privatelink.agentsvc.azure-automation.net",<br/>  "privatelink.database.windows.net",<br/>  "privatelink.sql.database.windows.net",<br/>  "privatelink.sql.azuresynapse.net",<br/>  "privatelink.dev.azuresynapse.net",<br/>  "privatelink.azuresynapse.net",<br/>  "privatelink.blob.core.windows.net",<br/>  "privatelink.table.core.windows.net",<br/>  "privatelink.queue.core.windows.net",<br/>  "privatelink.file.core.windows.net",<br/>  "privatelink.web.core.windows.net",<br/>  "privatelink.dfs.core.windows.net",<br/>  "privatelink.documents.azure.com",<br/>  "privatelink.mongo.cosmos.azure.com",<br/>  "privatelink.cassandra.cosmos.azure.com",<br/>  "privatelink.gremlin.cosmos.azure.com",<br/>  "privatelink.table.cosmos.azure.com",<br/>  "privatelink.postgres.database.azure.com",<br/>  "privatelink.mysql.database.azure.com",<br/>  "privatelink.mariadb.database.azure.com",<br/>  "privatelink.vaultcore.azure.net",<br/>  "privatelink.managedhsm.azure.net",<br/>  "privatelink.batch.azure.com",<br/>  "privatelink.search.windows.net",<br/>  "privatelink.azurecr.io",<br/>  "privatelink.azconfig.io",<br/>  "privatelink.siterecovery.windowsazure.com",<br/>  "privatelink.servicebus.windows.net",<br/>  "privatelink.azure-devices.net",<br/>  "privatelink.azure-devices-provisioning.net",<br/>  "privatelink.eventgrid.azure.net",<br/>  "privatelink.azurewebsites.net",<br/>  "scm.privatelink.azurewebsites.net",<br/>  "privatelink.api.azureml.ms",<br/>  "privatelink.notebooks.azure.net",<br/>  "privatelink.service.signalr.net",<br/>  "privatelink.monitor.azure.com",<br/>  "privatelink.oms.opinsights.azure.com",<br/>  "privatelink.ods.opinsights.azure.com",<br/>  "privatelink.datafactory.azure.net",<br/>  "privatelink.adf.azure.com",<br/>  "privatelink.redis.cache.windows.net",<br/>  "privatelink.redisenterprise.cache.azure.net",<br/>  "privatelink.purview.azure.com",<br/>  "privatelink.purviewstudio.azure.com",<br/>  "privatelink.digitaltwins.azure.net",<br/>  "privatelink.azurehdinsight.net",<br/>  "privatelink.his.arc.azure.com",<br/>  "privatelink.guestconfiguration.azure.com",<br/>  "privatelink.media.azure.net",<br/>  "privatelink.azurestaticapps.net",<br/>  "privatelink.prod.migration.windowsazure.com",<br/>  "privatelink.azure-api.net",<br/>  "privatelink.analysis.windows.net",<br/>  "privatelink.pbidedicated.windows.net",<br/>  "privatelink.tip1.powerquery.microsoft.com",<br/>  "privatelink.directline.botframework.com",<br/>  "privatelink.token.botframework.com",<br/>  "privatelink.workspace.azurehealthcareapis.com",<br/>  "privatelink.azuredatabricks.net",<br/>  "privatelink.cognitiveservices.azure.com",<br/>  "privatelink.openai.azure.com",<br/>  "privatelink.blob.storage.azure.net"<br/>]</pre> | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | The id of the resource group the zones are created in. The name is parsed from it; private DNS zones are global, so no location is needed. | `string` | n/a | yes |
| <a name="input_reverse_dns_zone_cidrs"></a> [reverse\_dns\_zone\_cidrs](#input\_reverse\_dns\_zone\_cidrs) | Set of IPv4 CIDRs to create in-addr.arpa reverse zones for. "192.168.1.0/24" creates "1.168.192.in-addr.arpa"; a non-octet prefix creates the documented classless dash-form zone, exact to the range ("192.0.2.128/26" creates "128-26.2.0.192.in-addr.arpa"). | `set(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to every zone and vnet link created by the module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_dns_zone_ids"></a> [private\_dns\_zone\_ids](#output\_private\_dns\_zone\_ids) | Map of zone name to zone id. |
| <a name="output_private_dns_zone_ids_zipmap"></a> [private\_dns\_zone\_ids\_zipmap](#output\_private\_dns\_zone\_ids\_zipmap) | Map of zone name to { name, id }, for easy composition with the private-endpoint module. |
| <a name="output_private_dns_zone_names"></a> [private\_dns\_zone\_names](#output\_private\_dns\_zone\_names) | The names of the zones created. |
| <a name="output_private_dns_zones"></a> [private\_dns\_zones](#output\_private\_dns\_zones) | The full azurerm\_private\_dns\_zone resources, keyed by zone name. |
| <a name="output_vnet_link_ids"></a> [vnet\_link\_ids](#output\_vnet\_link\_ids) | Map of "<zone>\|<link>" to vnet link id. |
| <a name="output_vnet_links"></a> [vnet\_links](#output\_vnet\_links) | The full azurerm\_private\_dns\_zone\_virtual\_network\_link resources, keyed by "<zone>\|<link>". |
<!-- END_TF_DOCS -->
