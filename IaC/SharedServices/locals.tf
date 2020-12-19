locals {
  ## This gathers all NSGs in this workspace and creates a list with unique names
  managedsubnetNsgNames = distinct([for subnet in var.subnets : subnet.nsgName if subnet.nsgName !=null])
  nsgNames = flatten([local.managedsubnetNsgNames])
}