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
