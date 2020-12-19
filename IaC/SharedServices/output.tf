output "resourceGroupName" {
  value = azurerm_resource_group.rg.name
}

output "resourceGroupID" {
  value = azurerm_resource_group.rg.id
}

output "logAnalyticWorkspaceName" {
  value = azurerm_log_analytics_workspace.laws.name
}

output "logAnalyticWorkspaceId" {
  value = azurerm_log_analytics_workspace.laws.id
}

output "keyVaultName" {
  value = azurerm_key_vault.kv.name
}

output "keyVaultId" {
  value = azurerm_key_vault.kv.id
}