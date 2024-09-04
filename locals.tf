locals {
  vnet_id_segments     = var.vnet_id != null ? split("/", var.vnet_id) : null
  vnet_name            = var.vnet_id != null ? element(local.vnet_id_segments, length(local.vnet_id_segments) - 1) : null
  hub_vnet_id_segments = var.hub_vnet_id != null ? split("/", var.hub_vnet_id) : null
  hub_vnet_name        = var.hub_vnet_id != null ? element(local.hub_vnet_id_segments, length(local.hub_vnet_id_segments) - 1) : null
}
