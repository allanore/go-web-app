###################################################
# Resources not managed by this module
###################################################

data "azurerm_key_vault" "kv" {
  name                = var.keyVaultName
  resource_group_name = var.sharedServicesRgName
}


data "azurerm_key_vault_secret" "vmPwd" {
  key_vault_id  = data.azurerm_key_vault.kv.id
  name          = var.vmPwdName
}

data "azurerm_key_vault_secret" "sqlPwd" {
  key_vault_id  = data.azurerm_key_vault.kv.id
  name          = var.sqlPwdName
}

data "azurerm_log_analytics_workspace" "laws" {
  name                = var.updateMgmtLaw.name
  resource_group_name = var.sharedServicesRgName
}

data "azurerm_subnet" "subnet" {
  name                  = var.subnetName
  virtual_network_name  = var.vnetName
  resource_group_name   = var.sharedServicesRgName
}

###################################################
# Managed Resources
###################################################

#### Resource Group ####

resource "azurerm_resource_group" "rg" {
  name      = var.rgName
  location  = var.rgLocation
  tags      = var.tags
}

#### Virtual Machines ####


resource "azurerm_network_interface" "linux" {
  for_each            = { for nic in var.linuxVMs:
                          nic.name => nic} 
  name                = "${each.value.name}-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "${each.value.name}-ipconfig"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "windows" {
  for_each            = { for nic in var.windowsVMs:
                          nic.name => nic} 
  name                = "${each.value.name}-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "${each.value.name}-ipconfig"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "linuxvm" {
  for_each                      = { for vm in var.linuxVMs:
                                    vm.name => vm} 

  name                            = each.value.name
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = each.value.sku
  admin_username                  = var.userName
  admin_password                  = data.azurerm_key_vault_secret.vmPwd.value
  priority                        = each.value.priority
  eviction_policy                 = "Deallocate"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.linux[each.value.name].id,
  ]

  source_image_reference {
    publisher = each.value.image_publisher
    offer     = each.value.image_offer
    sku       = each.value.image_sku
    version   = each.value.image_version
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = each.value.tags
}

resource "azurerm_windows_virtual_machine" "winvm" {
  for_each                      = { for vm in var.windowsVMs:
                                    vm.name => vm} 

  name                            = each.value.name
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = each.value.sku
  admin_username                  = var.userName
  admin_password                  = data.azurerm_key_vault_secret.vmPwd.value
  priority                        = each.value.priority
  eviction_policy                 = "Deallocate"
  network_interface_ids = [
    azurerm_network_interface.windows[each.value.name].id,
  ]

  source_image_reference {
    publisher = each.value.image_publisher
    offer     = each.value.image_offer
    sku       = each.value.image_sku
    version   = each.value.image_version
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = each.value.tags
}

resource "azurerm_virtual_machine_extension" "win_vm_ext_omsagent" {
  for_each                    = { for vm in var.windowsVMs:
                                  vm.name => vm}

  name                        = "OMSExtension"
  virtual_machine_id          = azurerm_windows_virtual_machine.winvm[each.value.name].id
  publisher                   = "Microsoft.EnterpriseCloud.Monitoring"
  type                        = "MicrosoftMonitoringAgent"
  type_handler_version        = "1.0"
  auto_upgrade_minor_version  = true

  settings = <<SETTINGS
    {
      "workspaceId": "${data.azurerm_log_analytics_workspace.laws.workspace_id}"
    }
  SETTINGS
  
  protected_settings = <<SETTINGS
    {
      "workspaceKey": "${data.azurerm_log_analytics_workspace.laws.primary_shared_key}"
    }
  SETTINGS
}

resource "azurerm_virtual_machine_extension" "linux_vm_ext_omsagent" {
  for_each                    = { for vm in var.linuxVMs:
                                  vm.name => vm}

  name                        = "OMSExtension"
  virtual_machine_id          = azurerm_linux_virtual_machine.linuxvm[each.value.name].id
  publisher                   = "Microsoft.EnterpriseCloud.Monitoring"
  type                        = "OmsAgentForLinux"
  type_handler_version        = "1.13"
  auto_upgrade_minor_version  = true

  settings = <<SETTINGS
    {
      "workspaceId": "${data.azurerm_log_analytics_workspace.laws.workspace_id}"
    }
  SETTINGS
  
  protected_settings = <<SETTINGS
    {
      "workspaceKey": "${data.azurerm_log_analytics_workspace.laws.primary_shared_key}"
    }
  SETTINGS
}

#### SQL Server/DB ####

resource "azurerm_sql_server" "server" {
  name                         = var.sqlSvrName
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = var.sqlSvrVersion
  administrator_login          = var.sqlSvrUsername
  administrator_login_password = data.azurerm_key_vault_secret.vmPwd.value

  tags = var.tags
}

resource "azurerm_sql_database" "example" {
  name                = var.sqlDbName
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.server.name
  edition             = var.sqlDbEdition 
}

resource "azurerm_monitor_diagnostic_setting" "sqlDb" {
  name                        = join("-",[var.sqlDbName,"DiagSettings"])
  target_resource_id          = azurerm_sql_server.server.id
  log_analytics_workspace_id  = data.azurerm_log_analytics_workspace.laws.id

  metric {
    category = "AllMetrics"
  }
}
