variable "attempt_private_dns_zone_link_to_hub" {
  type        = bool
  description = "Whether the DNS zone being made should be linked to the hub"
  default     = false
}

variable "attempt_privatelink_dns_zone_link_to_hub" {
  type        = bool
  description = "Whether the DNS zone being made should be linked to the hub"
  default     = false
}

variable "create_default_privatelink_zones" {
  type        = bool
  description = "Whether or not the module should create all private link zones or be ran in standalone zone mode. defaults to false"
  default     = false
}

variable "create_private_dns_zone" {
  type        = bool
  description = "Whether or not to create a private DNS zone, defaults to false"
  default     = false
}

variable "hub_vnet_id" {
  type        = string
  description = "The ID of the hub vnet"
  default     = null
}

variable "link_to_vnet" {
  type        = bool
  description = "Whether or not the zone should be linked to the vnet, defaults to false"
  default     = false
}

variable "location" {
  description = "The location for this resource to be put in"
  type        = string
}

variable "private_dns_zone_name" {
  type        = string
  description = "The name of the private_dns_zone"
  default     = null
}

variable "privatelink_dns_zones" {
  type = set(object({
    resource_type = string
    subresource   = string
    zone_name     = string
    forwarders    = string
  }))
  description = "A set of objects which lists a MAJORITY of privatelink zones, to be used inside the module.  Please ensure you check for the latest DNS zones here before using this and expecting the result: https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns"
  default = [
    {
      resource_type = "Microsoft.Automation/automationAccounts"
      subresource   = "Webhook, DSCAndHybridWorker"
      zone_name     = "privatelink.azure-automation.net"
      forwarders    = "azure-automation.net"
    },
    {
      resource_type = "Microsoft.Sql/servers"
      subresource   = "sqlServer"
      zone_name     = "privatelink.database.windows.net"
      forwarders    = "database.windows.net"
    },
    {
      resource_type = "Microsoft.Sql/managedInstances"
      subresource   = ""
      zone_name     = "privatelink.sql.database.windows.net"
      forwarders    = "database.windows.net"
    },
    {
      resource_type = "Microsoft.Synapse/workspaces"
      subresource   = "Sql"
      zone_name     = "privatelink.sql.azuresynapse.net"
      forwarders    = "sql.azuresynapse.net"
    },
    {
      resource_type = "Microsoft.Synapse/workspaces"
      subresource   = "Dev"
      zone_name     = "privatelink.dev.azuresynapse.net"
      forwarders    = "dev.azuresynapse.net"
    },
    {
      resource_type = "Microsoft.Synapse/privateLinkHubs"
      subresource   = "Web"
      zone_name     = "privatelink.azuresynapse.net"
      forwarders    = "azuresynapse.net"
    },
    {
      resource_type = "Microsoft.Storage/storageAccounts"
      subresource   = "Blob"
      zone_name     = "privatelink.blob.core.windows.net"
      forwarders    = "blob.core.windows.net"
    },
    {
      resource_type = "Microsoft.Storage/storageAccounts"
      subresource   = "Table"
      zone_name     = "privatelink.table.core.windows.net"
      forwarders    = "table.core.windows.net"
    },
    {
      resource_type = "Microsoft.Storage/storageAccounts"
      subresource   = "Queue"
      zone_name     = "privatelink.queue.core.windows.net"
      forwarders    = "queue.core.windows.net"
    },
    {
      resource_type = "Microsoft.Storage/storageAccounts"
      subresource   = "File"
      zone_name     = "privatelink.file.core.windows.net"
      forwarders    = "file.core.windows.net"
    },
    {
      resource_type = "Microsoft.Storage/storageAccounts"
      subresource   = "Web"
      zone_name     = "privatelink.web.core.windows.net"
      forwarders    = "web.core.windows.net"
    },
    {
      resource_type = "Microsoft.Storage/storageAccounts"
      subresource   = "Data Lake File System Gen2"
      zone_name     = "privatelink.dfs.core.windows.net"
      forwarders    = "dfs.core.windows.net"
    },
    {
      resource_type = "Microsoft.DocumentDb/databaseAccounts"
      subresource   = "Sql"
      zone_name     = "privatelink.documents.azure.com"
      forwarders    = "documents.azure.com"
    },
    {
      resource_type = "Microsoft.DocumentDb/databaseAccounts"
      subresource   = "MongoDB"
      zone_name     = "privatelink.mongo.cosmos.azure.com"
      forwarders    = "mongo.cosmos.azure.com"
    },
    {
      resource_type = "Microsoft.DocumentDb/databaseAccounts"
      subresource   = "Cassandra"
      zone_name     = "privatelink.cassandra.cosmos.azure.com"
      forwarders    = "cassandra.cosmos.azure.com"
    },
    {
      resource_type = "Microsoft.DocumentDb/databaseAccounts"
      subresource   = "Gremlin"
      zone_name     = "privatelink.gremlin.cosmos.azure.com"
      forwarders    = "gremlin.cosmos.azure.com"
    },
    {
      resource_type = "Microsoft.DocumentDb/databaseAccounts"
      subresource   = "Table"
      zone_name     = "privatelink.table.cosmos.azure.com"
      forwarders    = "table.cosmos.azure.com"
    },
    {
      resource_type = "Microsoft.Batch/batchAccounts"
      subresource   = "batchAccount"
      zone_name     = "privatelink.batch.azure.com"
      forwarders    = "uksouth.batch.azure.com"
    },
    {
      resource_type = "Microsoft.DBforPostgreSQL/servers"
      subresource   = "postgresqlServer"
      zone_name     = "privatelink.postgres.database.azure.com"
      forwarders    = "postgres.database.azure.com"
    },
    {
      resource_type = "Microsoft.DBforMySQL/servers"
      subresource   = "mysqlServer"
      zone_name     = "privatelink.mysql.database.azure.com"
      forwarders    = "mysql.database.azure.com"
    },
    {
      resource_type = "Microsoft.DBforMariaDB/servers"
      subresource   = "mariadbServer"
      zone_name     = "privatelink.mariadb.database.azure.com"
      forwarders    = "mariadb.database.azure.com"
    },
    {
      resource_type = "Microsoft.KeyVault/vaults"
      subresource   = "vault"
      zone_name     = "privatelink.vaultcore.azure.net"
      forwarders    = "vault.azure.net"
    },
    {
      resource_type = "Microsoft.KeyVault/managedHSMs"
      subresource   = "Managed HSMs"
      zone_name     = "privatelink.managedhsm.azure.net"
      forwarders    = "managedhsm.azure.net"
    },
    {
      resource_type = "Microsoft.ContainerService/managedClusters"
      subresource   = "management"
      zone_name     = "privatelink.uksouth.azmk8s.io"
      forwarders    = "uksouth.azmk8s.io"
    },
    {
      resource_type = "Microsoft.Search/searchServices"
      subresource   = "searchService"
      zone_name     = "privatelink.search.windows.net"
      forwarders    = "search.windows.net"
    },
    {
      resource_type = "Microsoft.ContainerRegistry/registries"
      subresource   = "registry"
      zone_name     = "privatelink.azurecr.io"
      forwarders    = "azurecr.io"
    },
    {
      resource_type = "Microsoft.AppConfiguration/configurationStores"
      subresource   = "configurationStores"
      zone_name     = "privatelink.azconfig.io"
      forwarders    = "azconfig.io"
    },
    {
      resource_type = "Microsoft.RecoveryServices/vaults"
      subresource   = "AzureBackup"
      zone_name     = "privatelink.uksouth.backup.windowsazure.com"
      forwarders    = "uksouth.backup.windowsazure.com"
    },
    {
      resource_type = "Microsoft.RecoveryServices/vaults"
      subresource   = "AzureSiteRecovery"
      zone_name     = "privatelink.siterecovery.windowsazure.com"
      forwarders    = "uksouth.siterecovery.windowsazure.com"
    },
    {
      resource_type = "Microsoft.EventHub/namespaces"
      subresource   = "namespace"
      zone_name     = "privatelink.servicebus.windows.net"
      forwarders    = "servicebus.windows.net"
    },
    {
      resource_type = "Microsoft.Devices/IotHubs"
      subresource   = "iotHub"
      zone_name     = "privatelink.azure-devices.net"
      forwarders    = "azure-devices.net"
    },
    {
      resource_type = "Microsoft.Devices/ProvisioningServices"
      subresource   = "iotDps"
      zone_name     = "privatelink.azure-devices-provisioning.net"
      forwarders    = "azure-devices-provisioning.net"
    },
    {
      resource_type = "Microsoft.EventGrid/topics"
      subresource   = "topic"
      zone_name     = "privatelink.eventgrid.azure.net"
      forwarders    = "eventgrid.azure.net"
    },
    {
      resource_type = "Microsoft.Web/sites"
      subresource   = "sites"
      zone_name     = "privatelink.azurewebsites.net"
      forwarders    = "azurewebsites.net"
    },
    {
      resource_type = "Microsoft.Web/sites"
      subresource   = "sites"
      zone_name     = "scm.privatelink.azurewebsites.net"
      forwarders    = "scm.azurewebsites.net"
    },
    {
      resource_type = "Microsoft.MachineLearningServices/workspaces"
      subresource   = "amlworkspace"
      zone_name     = "privatelink.api.azureml.ms"
      forwarders    = "api.azureml.ms"
    },
    {
      resource_type = "Microsoft.SignalRService/SignalR"
      subresource   = "signalR"
      zone_name     = "privatelink.service.signalr.net"
      forwarders    = "service.signalr.net"
    },
    {
      resource_type = "Microsoft.Insights/privateLinkScopes"
      subresource   = "azuremonitor"
      zone_name     = "privatelink.monitor.azure.com"
      forwarders    = "monitor.azure.com"
    },
    {
      resource_type = "Microsoft.Insights/privateLinkScopes"
      subresource   = "omsagent"
      zone_name     = "privatelink.oms.opinsights.azure.com"
      forwarders    = "oms.opinsights.azure.com"
    },
    {
      resource_type = "Microsoft.Insights/privateLinkScopes"
      subresource   = "odsagent"
      zone_name     = "privatelink.ods.opinsights.azure.com"
      forwarders    = "ods.opinsights.azure.com"
    },
    {
      resource_type = "Microsoft.Insights/privateLinkScopes"
      subresource   = "agentsvc"
      zone_name     = "privatelink.agentsvc.azure-automation.net"
      forwarders    = "agentsvc.azure-automation.net"
    },
    {
      resource_type = "Microsoft.StorageSync/storageSyncServices"
      subresource   = "afs"
      zone_name     = "uksouth.privatelink.afs.azure.net"
      forwarders    = "uksouth.afs.azure.net"
    },
    {
      resource_type = "Microsoft.DataFactory/factories"
      subresource   = "dataFactory"
      zone_name     = "privatelink.datafactory.azure.net"
      forwarders    = "datafactory.azure.net"
    },
    {
      resource_type = "Microsoft.DataFactory/factories"
      subresource   = "portal"
      zone_name     = "privatelink.adf.azure.com"
      forwarders    = "adf.azure.com"
    },
    {
      resource_type = "Microsoft.Cache/Redis"
      subresource   = "redisCache"
      zone_name     = "privatelink.redis.cache.windows.net"
      forwarders    = "redis.cache.windows.net"
    },
    {
      resource_type = "Microsoft.Cache/RedisEnterprise"
      subresource   = "redisEnterprise"
      zone_name     = "privatelink.redisenterprise.cache.azure.net"
      forwarders    = "redisenterprise.cache.azure.net"
    },
    {
      resource_type = "Microsoft.Purview"
      subresource   = "account"
      zone_name     = "privatelink.purview.azure.com"
      forwarders    = "purview.azure.com"
    },
    {
      resource_type = "Microsoft.Purview"
      subresource   = "portal"
      zone_name     = "privatelink.purviewstudio.azure.com"
      forwarders    = "purview.azure.com"
    },
    {
      resource_type = "Microsoft.DigitalTwins"
      subresource   = "digitalTwinsInstances"
      zone_name     = "privatelink.digitaltwins.azure.net"
      forwarders    = "digitaltwins.azure.net"
    },
    {
      resource_type = "Microsoft.HDInsight"
      subresource   = null
      zone_name     = "privatelink.azurehdinsight.net"
      forwarders    = "azurehdinsight.net"
    },
    {
      resource_type = "Microsoft.HybridCompute"
      subresource   = "hybridcompute"
      zone_name     = "privatelink.his.arc.azure.com"
      forwarders    = "his.arc.azure.com"
    },
    {
      resource_type = "Microsoft.Media"
      subresource   = "keydelivery"
      zone_name     = "privatelink.media.azure.net"
      forwarders    = "media.azure.net"
    },
    {
      resource_type = "Microsoft.Kusto"
      subresource   = ""
      zone_name     = "privatelink.uksouth.kusto.windows.net"
      forwarders    = "uksouth.kusto.windows.net"
    },
    {
      resource_type = "Microsoft.Web/staticSites"
      subresource   = "staticSites"
      zone_name     = "privatelink.azurestaticapps.net"
      forwarders    = "azurestaticapps.net"
    },
    {
      resource_type = "Microsoft.Migrate"
      subresource   = ""
      zone_name     = "privatelink.prod.migration.windowsazure.com"
      forwarders    = "prod.migration.windowsazure.com"
    },
    {
      resource_type = "Microsoft.ApiManagement/service"
      subresource   = "gateway"
      zone_name     = "privatelink.azure-api.net"
      forwarders    = "azure-api.net"
    },
    {
      resource_type = "Microsoft.PowerBI/privateLinkServicesForPowerBI"
      subresource   = ""
      zone_name     = "privatelink.analysis.windows.net"
      forwarders    = "analysis.windows.net"
    },
    {
      resource_type = "Microsoft.BotService/botServices"
      subresource   = "Bot"
      zone_name     = "privatelink.directline.botframework.com"
      forwarders    = "europe.directline.botframework.com"
    },
    {
      resource_type = "Microsoft.BotService/botServices"
      subresource   = "Token"
      zone_name     = "privatelink.token.botframework.com"
      forwarders    = "europe.token.botframework.com"
    },
    {
      resource_type = "Microsoft.HealthcareApis/workspaces"
      subresource   = "healthcareworkspace"
      zone_name     = "privatelink.workspace.azurehealthcareapis.com"
      forwarders    = "workspace.azurehealthcareapis.com"
    },
    {
      resource_type = "Microsoft.Databricks/workspaces"
      subresource   = "databricks_ui_api, browser_authentication"
      zone_name     = "privatelink.azuredatabricks.net"
      forwarders    = ""
    }
  ]
}

variable "rg_name" {
  description = "The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists"
  type        = string
}

variable "soa_record" {
  type        = any
  description = "The SOA record block is one is used"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."
}

variable "vnet_id" {
  type        = string
  description = "The vnet id the dns zones should be linked to"
  default     = null
}

variable "vnet_link_name" {
  type        = string
  description = "The name of the vnet link if one is made, defaults to null"
  default     = null
}



