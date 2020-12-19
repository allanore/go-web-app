output "resourceGroupName" {
  value = azurerm_resource_group.rg.name
}

output "resourceGroupID" {
  value = azurerm_resource_group.rg.id
}

output "linuxVMs"{
  value = [
    for vm in azurerm_linux_virtual_machine.linuxvm: map("name", vm.name, "id", vm.id) 
  ]
}

# output "windowsVMs"{
#   value = [
#     for vm in azurerm_linux_virtual_machine.winvm: map("name", vm.name, "id", vm.id) 
#   ]
# }