variable "create_default_privatelink_zones" {
  description = "Create the full canonical set of global Azure Private Link DNS zones (privatelink_dns_zones). Off by default."
  type        = bool
  default     = false
}

variable "create_regional_privatelink_zones" {
  description = "Create the region-specific privatelink zones (AKS, backup, file sync, Kusto). Requires location. Off by default."
  type        = bool
  default     = false
}

# Vnet links applied to every zone the module creates. The common case is linking all zones to the
# hub vnet; per-zone vnet_links (in private_dns_zones) are merged on top of these.
variable "default_vnet_links" {
  description = "Vnet links added to every zone this module creates, keyed by link name. Merged with any per-zone vnet_links."
  type = map(object({
    virtual_network_id   = string
    registration_enabled = optional(bool, false)
    resolution_policy    = optional(string)
    tags                 = optional(map(string))
  }))
  default = {}
}

variable "location" {
  description = "Azure region used only to render the regional privatelink zone names (for example uksouth in privatelink.uksouth.azmk8s.io). Required when create_regional_privatelink_zones is true; otherwise ignored."
  type        = string
  default     = null
}

# Forward zones, and any reverse zones you prefer to name explicitly (for example IPv6 ip6.arpa).
# Keyed by the full zone name. Reverse zones can also be derived from CIDRs, see reverse_dns_zone_cidrs.
variable "private_dns_zones" {
  description = "Map of private DNS zones to create, keyed by zone name (for example \"internal.example.com\" or \"1.168.192.in-addr.arpa\")."
  type = map(object({
    soa_record = optional(object({
      email        = string
      expire_time  = optional(number)
      minimum_ttl  = optional(number)
      refresh_time = optional(number)
      retry_time   = optional(number)
      ttl          = optional(number)
      tags         = optional(map(string))
    }))
    vnet_links = optional(map(object({
      virtual_network_id   = string
      registration_enabled = optional(bool, false)
      resolution_policy    = optional(string)
      tags                 = optional(map(string))
    })), {})
  }))
  default = {}
}

variable "privatelink_dns_zones" {
  description = "The set of global Azure Private Link zone names created when create_default_privatelink_zones is true. Defaults to the canonical global set; override to trim or extend it."
  type        = set(string)
  default = [
    "privatelink.azure-automation.net",
    "privatelink.agentsvc.azure-automation.net",
    "privatelink.database.windows.net",
    "privatelink.sql.database.windows.net",
    "privatelink.sql.azuresynapse.net",
    "privatelink.dev.azuresynapse.net",
    "privatelink.azuresynapse.net",
    "privatelink.blob.core.windows.net",
    "privatelink.table.core.windows.net",
    "privatelink.queue.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.web.core.windows.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.documents.azure.com",
    "privatelink.mongo.cosmos.azure.com",
    "privatelink.cassandra.cosmos.azure.com",
    "privatelink.gremlin.cosmos.azure.com",
    "privatelink.table.cosmos.azure.com",
    "privatelink.postgres.database.azure.com",
    "privatelink.mysql.database.azure.com",
    "privatelink.mariadb.database.azure.com",
    "privatelink.vaultcore.azure.net",
    "privatelink.managedhsm.azure.net",
    "privatelink.batch.azure.com",
    "privatelink.search.windows.net",
    "privatelink.azurecr.io",
    "privatelink.azconfig.io",
    "privatelink.siterecovery.windowsazure.com",
    "privatelink.servicebus.windows.net",
    "privatelink.azure-devices.net",
    "privatelink.azure-devices-provisioning.net",
    "privatelink.eventgrid.azure.net",
    "privatelink.azurewebsites.net",
    "scm.privatelink.azurewebsites.net",
    "privatelink.api.azureml.ms",
    "privatelink.notebooks.azure.net",
    "privatelink.service.signalr.net",
    "privatelink.monitor.azure.com",
    "privatelink.oms.opinsights.azure.com",
    "privatelink.ods.opinsights.azure.com",
    "privatelink.datafactory.azure.net",
    "privatelink.adf.azure.com",
    "privatelink.redis.cache.windows.net",
    "privatelink.redisenterprise.cache.azure.net",
    "privatelink.purview.azure.com",
    "privatelink.purviewstudio.azure.com",
    "privatelink.digitaltwins.azure.net",
    "privatelink.azurehdinsight.net",
    "privatelink.his.arc.azure.com",
    "privatelink.guestconfiguration.azure.com",
    "privatelink.media.azure.net",
    "privatelink.azurestaticapps.net",
    "privatelink.prod.migration.windowsazure.com",
    "privatelink.azure-api.net",
    "privatelink.analysis.windows.net",
    "privatelink.pbidedicated.windows.net",
    "privatelink.tip1.powerquery.microsoft.com",
    "privatelink.directline.botframework.com",
    "privatelink.token.botframework.com",
    "privatelink.workspace.azurehealthcareapis.com",
    "privatelink.azuredatabricks.net",
    "privatelink.cognitiveservices.azure.com",
    "privatelink.openai.azure.com",
    "privatelink.blob.storage.azure.net"
  ]
}

variable "resource_group_id" {
  description = "The id of the resource group the zones are created in. The name is parsed from it; private DNS zones are global, so no location is needed."
  type        = string

  validation {
    condition     = can(provider::azurerm::parse_resource_id(var.resource_group_id)) && lower(provider::azurerm::parse_resource_id(var.resource_group_id).resource_type) == "resourcegroups"
    error_message = "resource_group_id must be a resource group id (…/resourceGroups/<name>)."
  }
}

# IPv4 CIDRs whose in-addr.arpa reverse lookup zone should be created. Only octet-boundary prefixes
# Octet-aligned prefixes (/8, /16, /24) derive the exact classful zone; anything else derives the
# documented classless dash form, exact to the range. IPv6 reverse (ip6.arpa) zones should be
# passed by name in private_dns_zones.
variable "reverse_dns_zone_cidrs" {
  description = "Set of IPv4 CIDRs to create in-addr.arpa reverse zones for. \"192.168.1.0/24\" creates \"1.168.192.in-addr.arpa\"; a non-octet prefix creates the documented classless dash-form zone, exact to the range (\"192.0.2.128/26\" creates \"128-26.2.0.192.in-addr.arpa\")."
  type        = set(string)
  default     = []

  validation {
    condition = alltrue([
      for c in var.reverse_dns_zone_cidrs :
      can(cidrhost(c, 0)) && !strcontains(c, ":") && tonumber(split("/", c)[1]) >= 8 && tonumber(split("/", c)[1]) <= 32
    ])
    error_message = "Each reverse_dns_zone_cidrs entry must be an IPv4 CIDR with a prefix between /8 and /32."
  }
}

variable "tags" {
  description = "Tags applied to every zone and vnet link created by the module."
  type        = map(string)
  default     = {}
}
