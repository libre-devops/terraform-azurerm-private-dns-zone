```hcl
resource "azurerm_private_dns_zone" "private_dns_zone" {
  for_each            = var.create_private_dns_zone == true ? toset(["true"]) : toset([])
  name                = try(var.private_dns_zone_name, null)
  resource_group_name = try(var.rg_name, null)
  tags                = try(var.tags, null)

  dynamic "soa_record" {
    for_each = try(var.soa_record, null) != null ? [1] : []
    content {
      email        = try(var.soa_record["email"], null)
      expire_time  = try(var.soa_record["expire_time"], null)
      minimum_ttl  = try(var.soa_record["minimum_ttl"], null)
      refresh_time = try(var.soa_record["refresh_time"], null)
      retry_time   = try(var.soa_record["retry_time"], null)
      ttl          = try(var.soa_record["ttl"], null)
      tags         = try(var.soa_record["tags"], var.tags, null)
    }
  }
}

resource "azurerm_private_dns_zone" "privatelink_dns_zones" {
  for_each = var.create_default_privatelink_zones == true ? {
    for idx, value in var.privatelink_dns_zones : value.zone_name => merge(value, { index = idx })
  } : {}
  name                = each.key
  resource_group_name = try(var.rg_name, null)
  tags                = try(var.tags, null)

  dynamic "soa_record" {
    for_each = try(var.soa_record, null) != null ? [1] : []
    content {
      email        = try(var.soa_record["email"], null)
      expire_time  = try(var.soa_record["expire_time"], null)
      minimum_ttl  = try(var.soa_record["minimum_ttl"], null)
      refresh_time = try(var.soa_record["refresh_time"], null)
      retry_time   = try(var.soa_record["retry_time"], null)
      ttl          = try(var.soa_record["ttl"], null)
      tags         = try(var.soa_record["tags"], var.tags, null)
    }
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_link" {
  for_each = try(var.link_to_vnet, true) == true && var.create_private_dns_zone == true ? toset([
    "true"
  ]) : toset([])
  name                  = var.vnet_link_name == null ? "${lower(replace(azurerm_private_dns_zone.private_dns_zone[each.key].name, ".", "-"))}-link-to-${local.vnet_name}" : try(var.vnet_link_name, null)
  resource_group_name   = try(var.rg_name, null)
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone[each.key].name
  virtual_network_id    = try(var.vnet_id, null)
  tags                  = try(var.tags, null)
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_link_hub" {
  for_each = try(var.link_to_vnet, true) == true && var.create_private_dns_zone == true && var.attempt_private_dns_zone_link_to_hub == true ? toset([
    "true"
  ]) : toset([])
  name                  = var.vnet_link_name == null ? "${lower(replace(azurerm_private_dns_zone.private_dns_zone[each.key].name, ".", "-"))}-link-to-${local.hub_vnet_name}" : try(var.vnet_link_name, null)
  resource_group_name   = try(var.rg_name, null)
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone[each.key].name
  virtual_network_id    = try(var.hub_vnet_id, null)
  tags                  = try(var.tags, null)
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_dns_zone_link" {
  for_each = var.link_to_vnet == true && var.create_default_privatelink_zones == true ? {
    for idx, value in var.privatelink_dns_zones : value.zone_name => merge(value, { index = idx })
  } : {}
  name                  = var.vnet_link_name == null ? "${lower(replace(azurerm_private_dns_zone.privatelink_dns_zones[each.key].name, ".", "-"))}-link-to-${local.vnet_name}" : try(var.vnet_link_name, null)
  resource_group_name   = try(var.rg_name, null)
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_dns_zones[each.key].name
  virtual_network_id    = try(var.vnet_id, null)
  tags                  = try(var.tags, null)
}

resource "azurerm_private_dns_zone_virtual_network_link" "privatelink_dns_zone_link_hub" {
  for_each = try(var.link_to_vnet, true) == true && var.create_default_privatelink_zones == true && var.attempt_privatelink_dns_zone_link_to_hub == true ? {
    for idx, value in var.privatelink_dns_zones : value.zone_name => merge(value, { index = idx })
  } : {}
  name                  = var.vnet_link_name == null ? "${lower(replace(azurerm_private_dns_zone.privatelink_dns_zones[each.key].name, ".", "-"))}-link-to-${local.hub_vnet_name}" : try(var.vnet_link_name, null)
  resource_group_name   = try(var.rg_name, null)
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_dns_zones[each.key].name
  virtual_network_id    = try(var.hub_vnet_id, null)
  tags                  = try(var.tags, null)
}

```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.private_dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone.privatelink_dns_zones](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.private_dns_zone_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.private_dns_zone_link_hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.privatelink_dns_zone_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_dns_zone_virtual_network_link.privatelink_dns_zone_link_hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attempt_private_dns_zone_link_to_hub"></a> [attempt\_private\_dns\_zone\_link\_to\_hub](#input\_attempt\_private\_dns\_zone\_link\_to\_hub) | Whether the DNS zone being made should be linked to the hub | `bool` | `false` | no |
| <a name="input_attempt_privatelink_dns_zone_link_to_hub"></a> [attempt\_privatelink\_dns\_zone\_link\_to\_hub](#input\_attempt\_privatelink\_dns\_zone\_link\_to\_hub) | Whether the DNS zone being made should be linked to the hub | `bool` | `false` | no |
| <a name="input_create_default_privatelink_zones"></a> [create\_default\_privatelink\_zones](#input\_create\_default\_privatelink\_zones) | Whether or not the module should create all private link zones or be ran in standalone zone mode. defaults to false | `bool` | `false` | no |
| <a name="input_create_private_dns_zone"></a> [create\_private\_dns\_zone](#input\_create\_private\_dns\_zone) | Whether or not to create a private DNS zone, defaults to false | `bool` | `false` | no |
| <a name="input_hub_vnet_id"></a> [hub\_vnet\_id](#input\_hub\_vnet\_id) | The ID of the hub vnet | `string` | `null` | no |
| <a name="input_link_to_vnet"></a> [link\_to\_vnet](#input\_link\_to\_vnet) | Whether or not the zone should be linked to the vnet, defaults to false | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_private_dns_zone_name"></a> [private\_dns\_zone\_name](#input\_private\_dns\_zone\_name) | The name of the private\_dns\_zone | `string` | `null` | no |
| <a name="input_privatelink_dns_zones"></a> [privatelink\_dns\_zones](#input\_privatelink\_dns\_zones) | A set of objects which lists a MAJORITY of privatelink zones, to be used inside the module.  Please ensure you check for the latest DNS zones here before using this and expecting the result: https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns | <pre>set(object({<br>    resource_type = string<br>    subresource   = string<br>    zone_name     = string<br>    forwarders    = string<br>  }))</pre> | <pre>[<br>  {<br>    "forwarders": "azure-automation.net",<br>    "resource_type": "Microsoft.Automation/automationAccounts",<br>    "subresource": "Webhook, DSCAndHybridWorker",<br>    "zone_name": "privatelink.azure-automation.net"<br>  },<br>  {<br>    "forwarders": "database.windows.net",<br>    "resource_type": "Microsoft.Sql/servers",<br>    "subresource": "sqlServer",<br>    "zone_name": "privatelink.database.windows.net"<br>  },<br>  {<br>    "forwarders": "database.windows.net",<br>    "resource_type": "Microsoft.Sql/managedInstances",<br>    "subresource": "",<br>    "zone_name": "privatelink.sql.database.windows.net"<br>  },<br>  {<br>    "forwarders": "sql.azuresynapse.net",<br>    "resource_type": "Microsoft.Synapse/workspaces",<br>    "subresource": "Sql",<br>    "zone_name": "privatelink.sql.azuresynapse.net"<br>  },<br>  {<br>    "forwarders": "dev.azuresynapse.net",<br>    "resource_type": "Microsoft.Synapse/workspaces",<br>    "subresource": "Dev",<br>    "zone_name": "privatelink.dev.azuresynapse.net"<br>  },<br>  {<br>    "forwarders": "azuresynapse.net",<br>    "resource_type": "Microsoft.Synapse/privateLinkHubs",<br>    "subresource": "Web",<br>    "zone_name": "privatelink.azuresynapse.net"<br>  },<br>  {<br>    "forwarders": "blob.core.windows.net",<br>    "resource_type": "Microsoft.Storage/storageAccounts",<br>    "subresource": "Blob",<br>    "zone_name": "privatelink.blob.core.windows.net"<br>  },<br>  {<br>    "forwarders": "table.core.windows.net",<br>    "resource_type": "Microsoft.Storage/storageAccounts",<br>    "subresource": "Table",<br>    "zone_name": "privatelink.table.core.windows.net"<br>  },<br>  {<br>    "forwarders": "queue.core.windows.net",<br>    "resource_type": "Microsoft.Storage/storageAccounts",<br>    "subresource": "Queue",<br>    "zone_name": "privatelink.queue.core.windows.net"<br>  },<br>  {<br>    "forwarders": "file.core.windows.net",<br>    "resource_type": "Microsoft.Storage/storageAccounts",<br>    "subresource": "File",<br>    "zone_name": "privatelink.file.core.windows.net"<br>  },<br>  {<br>    "forwarders": "web.core.windows.net",<br>    "resource_type": "Microsoft.Storage/storageAccounts",<br>    "subresource": "Web",<br>    "zone_name": "privatelink.web.core.windows.net"<br>  },<br>  {<br>    "forwarders": "dfs.core.windows.net",<br>    "resource_type": "Microsoft.Storage/storageAccounts",<br>    "subresource": "Data Lake File System Gen2",<br>    "zone_name": "privatelink.dfs.core.windows.net"<br>  },<br>  {<br>    "forwarders": "documents.azure.com",<br>    "resource_type": "Microsoft.DocumentDb/databaseAccounts",<br>    "subresource": "Sql",<br>    "zone_name": "privatelink.documents.azure.com"<br>  },<br>  {<br>    "forwarders": "mongo.cosmos.azure.com",<br>    "resource_type": "Microsoft.DocumentDb/databaseAccounts",<br>    "subresource": "MongoDB",<br>    "zone_name": "privatelink.mongo.cosmos.azure.com"<br>  },<br>  {<br>    "forwarders": "cassandra.cosmos.azure.com",<br>    "resource_type": "Microsoft.DocumentDb/databaseAccounts",<br>    "subresource": "Cassandra",<br>    "zone_name": "privatelink.cassandra.cosmos.azure.com"<br>  },<br>  {<br>    "forwarders": "gremlin.cosmos.azure.com",<br>    "resource_type": "Microsoft.DocumentDb/databaseAccounts",<br>    "subresource": "Gremlin",<br>    "zone_name": "privatelink.gremlin.cosmos.azure.com"<br>  },<br>  {<br>    "forwarders": "table.cosmos.azure.com",<br>    "resource_type": "Microsoft.DocumentDb/databaseAccounts",<br>    "subresource": "Table",<br>    "zone_name": "privatelink.table.cosmos.azure.com"<br>  },<br>  {<br>    "forwarders": "uksouth.batch.azure.com",<br>    "resource_type": "Microsoft.Batch/batchAccounts",<br>    "subresource": "batchAccount",<br>    "zone_name": "privatelink.batch.azure.com"<br>  },<br>  {<br>    "forwarders": "postgres.database.azure.com",<br>    "resource_type": "Microsoft.DBforPostgreSQL/servers",<br>    "subresource": "postgresqlServer",<br>    "zone_name": "privatelink.postgres.database.azure.com"<br>  },<br>  {<br>    "forwarders": "mysql.database.azure.com",<br>    "resource_type": "Microsoft.DBforMySQL/servers",<br>    "subresource": "mysqlServer",<br>    "zone_name": "privatelink.mysql.database.azure.com"<br>  },<br>  {<br>    "forwarders": "mariadb.database.azure.com",<br>    "resource_type": "Microsoft.DBforMariaDB/servers",<br>    "subresource": "mariadbServer",<br>    "zone_name": "privatelink.mariadb.database.azure.com"<br>  },<br>  {<br>    "forwarders": "vault.azure.net",<br>    "resource_type": "Microsoft.KeyVault/vaults",<br>    "subresource": "vault",<br>    "zone_name": "privatelink.vaultcore.azure.net"<br>  },<br>  {<br>    "forwarders": "managedhsm.azure.net",<br>    "resource_type": "Microsoft.KeyVault/managedHSMs",<br>    "subresource": "Managed HSMs",<br>    "zone_name": "privatelink.managedhsm.azure.net"<br>  },<br>  {<br>    "forwarders": "uksouth.azmk8s.io",<br>    "resource_type": "Microsoft.ContainerService/managedClusters",<br>    "subresource": "management",<br>    "zone_name": "privatelink.uksouth.azmk8s.io"<br>  },<br>  {<br>    "forwarders": "search.windows.net",<br>    "resource_type": "Microsoft.Search/searchServices",<br>    "subresource": "searchService",<br>    "zone_name": "privatelink.search.windows.net"<br>  },<br>  {<br>    "forwarders": "azurecr.io",<br>    "resource_type": "Microsoft.ContainerRegistry/registries",<br>    "subresource": "registry",<br>    "zone_name": "privatelink.azurecr.io"<br>  },<br>  {<br>    "forwarders": "azconfig.io",<br>    "resource_type": "Microsoft.AppConfiguration/configurationStores",<br>    "subresource": "configurationStores",<br>    "zone_name": "privatelink.azconfig.io"<br>  },<br>  {<br>    "forwarders": "uksouth.backup.windowsazure.com",<br>    "resource_type": "Microsoft.RecoveryServices/vaults",<br>    "subresource": "AzureBackup",<br>    "zone_name": "privatelink.uksouth.backup.windowsazure.com"<br>  },<br>  {<br>    "forwarders": "uksouth.siterecovery.windowsazure.com",<br>    "resource_type": "Microsoft.RecoveryServices/vaults",<br>    "subresource": "AzureSiteRecovery",<br>    "zone_name": "privatelink.siterecovery.windowsazure.com"<br>  },<br>  {<br>    "forwarders": "servicebus.windows.net",<br>    "resource_type": "Microsoft.EventHub/namespaces",<br>    "subresource": "namespace",<br>    "zone_name": "privatelink.servicebus.windows.net"<br>  },<br>  {<br>    "forwarders": "azure-devices.net",<br>    "resource_type": "Microsoft.Devices/IotHubs",<br>    "subresource": "iotHub",<br>    "zone_name": "privatelink.azure-devices.net"<br>  },<br>  {<br>    "forwarders": "azure-devices-provisioning.net",<br>    "resource_type": "Microsoft.Devices/ProvisioningServices",<br>    "subresource": "iotDps",<br>    "zone_name": "privatelink.azure-devices-provisioning.net"<br>  },<br>  {<br>    "forwarders": "eventgrid.azure.net",<br>    "resource_type": "Microsoft.EventGrid/topics",<br>    "subresource": "topic",<br>    "zone_name": "privatelink.eventgrid.azure.net"<br>  },<br>  {<br>    "forwarders": "azurewebsites.net",<br>    "resource_type": "Microsoft.Web/sites",<br>    "subresource": "sites",<br>    "zone_name": "privatelink.azurewebsites.net"<br>  },<br>  {<br>    "forwarders": "scm.azurewebsites.net",<br>    "resource_type": "Microsoft.Web/sites",<br>    "subresource": "sites",<br>    "zone_name": "scm.privatelink.azurewebsites.net"<br>  },<br>  {<br>    "forwarders": "api.azureml.ms",<br>    "resource_type": "Microsoft.MachineLearningServices/workspaces",<br>    "subresource": "amlworkspace",<br>    "zone_name": "privatelink.api.azureml.ms"<br>  },<br>  {<br>    "forwarders": "service.signalr.net",<br>    "resource_type": "Microsoft.SignalRService/SignalR",<br>    "subresource": "signalR",<br>    "zone_name": "privatelink.service.signalr.net"<br>  },<br>  {<br>    "forwarders": "monitor.azure.com",<br>    "resource_type": "Microsoft.Insights/privateLinkScopes",<br>    "subresource": "azuremonitor",<br>    "zone_name": "privatelink.monitor.azure.com"<br>  },<br>  {<br>    "forwarders": "oms.opinsights.azure.com",<br>    "resource_type": "Microsoft.Insights/privateLinkScopes",<br>    "subresource": "omsagent",<br>    "zone_name": "privatelink.oms.opinsights.azure.com"<br>  },<br>  {<br>    "forwarders": "ods.opinsights.azure.com",<br>    "resource_type": "Microsoft.Insights/privateLinkScopes",<br>    "subresource": "odsagent",<br>    "zone_name": "privatelink.ods.opinsights.azure.com"<br>  },<br>  {<br>    "forwarders": "agentsvc.azure-automation.net",<br>    "resource_type": "Microsoft.Insights/privateLinkScopes",<br>    "subresource": "agentsvc",<br>    "zone_name": "privatelink.agentsvc.azure-automation.net"<br>  },<br>  {<br>    "forwarders": "uksouth.afs.azure.net",<br>    "resource_type": "Microsoft.StorageSync/storageSyncServices",<br>    "subresource": "afs",<br>    "zone_name": "uksouth.privatelink.afs.azure.net"<br>  },<br>  {<br>    "forwarders": "datafactory.azure.net",<br>    "resource_type": "Microsoft.DataFactory/factories",<br>    "subresource": "dataFactory",<br>    "zone_name": "privatelink.datafactory.azure.net"<br>  },<br>  {<br>    "forwarders": "adf.azure.com",<br>    "resource_type": "Microsoft.DataFactory/factories",<br>    "subresource": "portal",<br>    "zone_name": "privatelink.adf.azure.com"<br>  },<br>  {<br>    "forwarders": "redis.cache.windows.net",<br>    "resource_type": "Microsoft.Cache/Redis",<br>    "subresource": "redisCache",<br>    "zone_name": "privatelink.redis.cache.windows.net"<br>  },<br>  {<br>    "forwarders": "redisenterprise.cache.azure.net",<br>    "resource_type": "Microsoft.Cache/RedisEnterprise",<br>    "subresource": "redisEnterprise",<br>    "zone_name": "privatelink.redisenterprise.cache.azure.net"<br>  },<br>  {<br>    "forwarders": "purview.azure.com",<br>    "resource_type": "Microsoft.Purview",<br>    "subresource": "account",<br>    "zone_name": "privatelink.purview.azure.com"<br>  },<br>  {<br>    "forwarders": "purview.azure.com",<br>    "resource_type": "Microsoft.Purview",<br>    "subresource": "portal",<br>    "zone_name": "privatelink.purviewstudio.azure.com"<br>  },<br>  {<br>    "forwarders": "digitaltwins.azure.net",<br>    "resource_type": "Microsoft.DigitalTwins",<br>    "subresource": "digitalTwinsInstances",<br>    "zone_name": "privatelink.digitaltwins.azure.net"<br>  },<br>  {<br>    "forwarders": "azurehdinsight.net",<br>    "resource_type": "Microsoft.HDInsight",<br>    "subresource": null,<br>    "zone_name": "privatelink.azurehdinsight.net"<br>  },<br>  {<br>    "forwarders": "his.arc.azure.com",<br>    "resource_type": "Microsoft.HybridCompute",<br>    "subresource": "hybridcompute",<br>    "zone_name": "privatelink.his.arc.azure.com"<br>  },<br>  {<br>    "forwarders": "media.azure.net",<br>    "resource_type": "Microsoft.Media",<br>    "subresource": "keydelivery",<br>    "zone_name": "privatelink.media.azure.net"<br>  },<br>  {<br>    "forwarders": "uksouth.kusto.windows.net",<br>    "resource_type": "Microsoft.Kusto",<br>    "subresource": "",<br>    "zone_name": "privatelink.uksouth.kusto.windows.net"<br>  },<br>  {<br>    "forwarders": "azurestaticapps.net",<br>    "resource_type": "Microsoft.Web/staticSites",<br>    "subresource": "staticSites",<br>    "zone_name": "privatelink.azurestaticapps.net"<br>  },<br>  {<br>    "forwarders": "prod.migration.windowsazure.com",<br>    "resource_type": "Microsoft.Migrate",<br>    "subresource": "",<br>    "zone_name": "privatelink.prod.migration.windowsazure.com"<br>  },<br>  {<br>    "forwarders": "azure-api.net",<br>    "resource_type": "Microsoft.ApiManagement/service",<br>    "subresource": "gateway",<br>    "zone_name": "privatelink.azure-api.net"<br>  },<br>  {<br>    "forwarders": "analysis.windows.net",<br>    "resource_type": "Microsoft.PowerBI/privateLinkServicesForPowerBI",<br>    "subresource": "",<br>    "zone_name": "privatelink.analysis.windows.net"<br>  },<br>  {<br>    "forwarders": "europe.directline.botframework.com",<br>    "resource_type": "Microsoft.BotService/botServices",<br>    "subresource": "Bot",<br>    "zone_name": "privatelink.directline.botframework.com"<br>  },<br>  {<br>    "forwarders": "europe.token.botframework.com",<br>    "resource_type": "Microsoft.BotService/botServices",<br>    "subresource": "Token",<br>    "zone_name": "privatelink.token.botframework.com"<br>  },<br>  {<br>    "forwarders": "workspace.azurehealthcareapis.com",<br>    "resource_type": "Microsoft.HealthcareApis/workspaces",<br>    "subresource": "healthcareworkspace",<br>    "zone_name": "privatelink.workspace.azurehealthcareapis.com"<br>  },<br>  {<br>    "forwarders": "",<br>    "resource_type": "Microsoft.Databricks/workspaces",<br>    "subresource": "databricks_ui_api, browser_authentication",<br>    "zone_name": "privatelink.azuredatabricks.net"<br>  }<br>]</pre> | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_soa_record"></a> [soa\_record](#input\_soa\_record) | The SOA record block is one is used | `any` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | n/a | yes |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | The vnet id the dns zones should be linked to | `string` | `null` | no |
| <a name="input_vnet_link_name"></a> [vnet\_link\_name](#input\_vnet\_link\_name) | The name of the vnet link if one is made, defaults to null | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_number_of_record_sets"></a> [dns\_number\_of\_record\_sets](#output\_dns\_number\_of\_record\_sets) | The max number of virtual network links with registration |
| <a name="output_dns_zone_id"></a> [dns\_zone\_id](#output\_dns\_zone\_id) | The dns zone ids |
| <a name="output_dns_zone_max_number_of_record_sets"></a> [dns\_zone\_max\_number\_of\_record\_sets](#output\_dns\_zone\_max\_number\_of\_record\_sets) | The max number of record sets |
| <a name="output_dns_zone_max_number_of_virtual_network_links"></a> [dns\_zone\_max\_number\_of\_virtual\_network\_links](#output\_dns\_zone\_max\_number\_of\_virtual\_network\_links) | The dns max number of virtual network links |
| <a name="output_dns_zone_max_number_of_virtual_network_links_with_registration"></a> [dns\_zone\_max\_number\_of\_virtual\_network\_links\_with\_registration](#output\_dns\_zone\_max\_number\_of\_virtual\_network\_links\_with\_registration) | The max number of virtual network links with registration |
| <a name="output_dns_zone_name"></a> [dns\_zone\_name](#output\_dns\_zone\_name) | The dns zone name |
| <a name="output_vnet_link_id"></a> [vnet\_link\_id](#output\_vnet\_link\_id) | The vnet link ids |
