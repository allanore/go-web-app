###################################################
# Resources not managed by this TF Module`
###################################################

data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

###################################################
# Resource Group Resource
###################################################

resource "azurerm_resource_group" "rg" {
  name      = var.rgName
  location  = var.rgLocation
  tags      = var.tags
}

###################################################
# Log Analytic Resources
###################################################

resource "azurerm_log_analytics_workspace" "laws" {
  name                = var.logAnalyticsName
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.logAnalyticsSku
  retention_in_days   = var.logAnalyticsRetention
  tags                = var.tags
}

###################################################
# KeyVault Resources
###################################################

resource "azurerm_key_vault" "kv" {
  name                        = var.keyVaultName
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = var.enableForDiskEncryption
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_enabled         = var.softDeleteEnabled
  soft_delete_retention_days  = var.softDeleteRetention
  purge_protection_enabled    = var.purgeDeleteEnabled

  sku_name = var.keyVaultSku

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = ["${chomp(data.http.myip.body)}/32"]
  }

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "kvpolicy" {
  key_vault_id = azurerm_key_vault.kv.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions         = var.keyVault_keyAccessPolicy
  secret_permissions      = var.keyVault_secretAccessPolicy
  certificate_permissions = var.keyVault_certAccessPolicy
}


resource "random_password" "wfePwd" {
  length=16
  special = true
}

resource "azurerm_key_vault_secret" "wfePwd" {
  name         = "WFE-VM-Pwd"
  value        = random_password.wfePwd.result
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault_access_policy.kvpolicy]
}

resource "random_password" "dbPwd" {
  length=16
  special = true
}

resource "azurerm_key_vault_secret" "dbPwd" {
  name         = "DB-Pwd"
  value        = random_password.dbPwd.result
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_key_vault_access_policy.kvpolicy]
}

###################################################
# Vnet Resources
###################################################

resource "azurerm_virtual_network" "main" {
  name                = var.vnetName
  address_space       = var.vnetPrefix
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_subnet" "subnets" {
  for_each                                        = { for subnet in var.subnets:
                                                      subnet.subnetName => subnet }

  name                                            = each.value.subnetName
  address_prefixes                                = toset([each.value.addressPrefix])
  virtual_network_name                            = each.value.vnetName
  resource_group_name                             = azurerm_resource_group.rg.name
  service_endpoints                               = each.value.endpoints
  enforce_private_link_endpoint_network_policies  = each.value.enforcePrivateLinkEndpointPolicies
  enforce_private_link_service_network_policies   = each.value.enforcePrivateLinkServicePolicies

  dynamic "delegation" {
    for_each = { for delegation in var.subnets:
                  "${delegation.subnetName}:${delegation.delegationName}" => delegation
                  if delegation.delegationEnabled == true && delegation.subnetName == each.value.subnetName }
    content {
      name = delegation.value.delegationName

      service_delegation { 
        name    = delegation.value.serviceName
        actions = delegation.value.serviceActions
      }
    }
  }

  depends_on            = [azurerm_virtual_network.main]  
}

resource "azurerm_network_security_group" "nsgs" {
  for_each            = { for nsg in local.nsgNames:
                          nsg => nsg }

  name                = each.value
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = var.tags
  depends_on          = [azurerm_virtual_network.main]
}

resource "azurerm_network_security_rule" "nsgRules" {
  for_each                                    = { for rule in var.nsgs:
                                                  "${rule.nsgName}:${rule.name}" => rule }

  resource_group_name                         = azurerm_resource_group.rg.name
  network_security_group_name                 = each.value.nsgName
  name                                        = each.value.name
  description                                 = each.value.description
  protocol                                    = each.value.protocol
  source_port_range                           = each.value.source_port_range
  source_port_ranges                          = each.value.source_port_ranges
  destination_port_range                      = each.value.destination_port_range
  destination_port_ranges                     = each.value.destination_port_ranges
  source_address_prefix                       = each.value.source_address_prefix
  source_address_prefixes                     = each.value.source_address_prefixes
  source_application_security_group_ids       = each.value.source_application_security_group_ids
  destination_address_prefix                  = each.value.destination_address_prefix
  destination_address_prefixes                = each.value.destination_address_prefixes
  destination_application_security_group_ids  = each.value.destination_application_security_group_ids
  access                                      = each.value.access
  priority                                    = each.value.priority
  direction                                   = each.value.direction
  depends_on                                  = [azurerm_network_security_group.nsgs] 
}

resource "azurerm_subnet_network_security_group_association" "assocCustomNSGSubnets" {
  for_each                    = { for subnet in var.subnets:
                                  "${subnet.subnetName}:${subnet.nsgName}" => subnet 
                                  if subnet.nsgName != null }

  subnet_id                   = azurerm_subnet.subnets[each.value.subnetName].id
  network_security_group_id   = azurerm_network_security_group.nsgs[each.value.nsgName].id 
  depends_on                  = [azurerm_subnet.subnets, azurerm_network_security_group.nsgs]
}