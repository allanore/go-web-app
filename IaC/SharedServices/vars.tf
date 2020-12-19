###################################################
# Universal Variables
###################################################

variable "rgName" {
  type    = string
  default = "cloudSkills-sharedServices-rg"
}

variable "rgLocation" {
  type    = string
  default = "eastus2"
}

variable "tags" {
  type    = map(string)
  default = {
    Owner         = "CloudSkills"
    Environment   = "Demo Lab"
    BudgetCode    = "abc123"
  }
}


###################################################
# Log Analytics Variables
###################################################

variable "logAnalyticsName" {
  type    = string
  default = "cloudSkillsDemo-LA"
}

variable "logAnalyticsSku" {
  type    = string
  default = "pergb2018"
}

variable "logAnalyticsRetention" {
  type    = number
  default = 30
}


###################################################
# KeyVault Variables
###################################################

variable "keyVaultName" {
  type = string
  default = "cloudSkillsDemo-KV"
}

variable "keyVaultSku" {
  type = string
  default = "standard"
}

variable "enableForDiskEncryption" {
  type = bool
  default = false
}

variable "softDeleteEnabled" {
  type = bool
  default = true
}

variable "softDeleteRetention" {
  type = number
  default = 7
}

variable "purgeDeleteEnabled" {
  type = bool
  default = false
}

variable "keyVault_secretAccessPolicy" {
  type = list(string)
  default = [
    "get",
    "list",
    "set",
    "delete",
    "recover"
  ]
}

variable "keyVault_keyAccessPolicy" {
  type = list(string)
  default = [
    "get",
    "list",
    "delete"
  ]
}

variable "keyVault_certAccessPolicy" {
  type = list(string)
  default = [
    "get",
    "list",
    "delete"
  ]
}


###################################################
# Vnet Variables
###################################################

variable "vnetName" {
  type    = string
  default = "csDemoVnet"
}

variable "vnetPrefix" {
  type    = list(string)
  default = ["10.10.10.0/24"]
}

variable "subnets" {
  description = "Subnets for the dev-qa-staging environment"
  type = list(object({
    subnetName                          = string
    vnetName                            = string
    addressPrefix                       = string
    routeTableName                      = string
    endpoints                           = list(string)
    nsgName                             = string
    delegationEnabled                   = bool
    delegationName                      = string
    serviceName                         = string
    serviceActions                      = list(string)
    enforcePrivateLinkEndpointPolicies  = bool
    enforcePrivateLinkServicePolicies   = bool
  }))
  default = [
    {
      subnetName                          = "csWFE_10.10.10.0_27"
      vnetName                            = "csDemoVnet"
      addressPrefix                       = "10.10.10.0/27"
      routeTableName                      = null
      endpoints                           = []
      nsgName                             = "cs-wfe-nsg"
      delegationEnabled                   = false
      delegationName                      = null
      serviceName                         = null
      serviceActions                      = []
      enforcePrivateLinkEndpointPolicies  = false
      enforcePrivateLinkServicePolicies   = false
    },
    {
      subnetName                          = "csDB_10.10.10.32_27"
      vnetName                            = "csDemoVnet"
      addressPrefix                       = "10.10.10.32/27"
      routeTableName                      = null
      endpoints                           = []
      nsgName                             = "cs-db-nsg"
      delegationEnabled                   = false
      delegationName                      = null
      serviceName                         = null
      serviceActions                      = []
      enforcePrivateLinkEndpointPolicies  = false
      enforcePrivateLinkServicePolicies   = false
    }
  ]
}

###################################################
# Vnet Variables
###################################################


variable "nsgs" {
  description = "List of NSGs and associated rules that need to be created"
  type        = list(object({
    nsgName                                     = string
    name                                        = string
    description                                 = string
    protocol                                    = string
    source_port_range                           = string
    source_port_ranges                          = list(string)
    destination_port_range                      = string
    destination_port_ranges                     = list(string)
    source_address_prefix                       = string
    source_address_prefixes                     = list(string)
    source_application_security_group_ids       = list(string)
    destination_address_prefix                  = string
    destination_address_prefixes                = list(string)
    destination_application_security_group_ids  = list(string)
    access                                      = string
    priority                                    = number
    direction                                   = string
  }))
  default     = [
  #--------------------------------------------------------------------------
  # cs-db-wfe
  #--------------------------------------------------------------------------
    {
      nsgName                                     = "cs-db-nsg"
      name                                        = "Allow_1433_in"
      description                                 = null
      protocol                                    = "TCP"
      source_port_range                           = "*"
      source_port_ranges                          = null
      destination_port_range                      = "1433"
      destination_port_ranges                     = null
      source_address_prefix                       = "10.10.10.0/27"
      source_address_prefixes                     = null
      source_application_security_group_ids       = null
      destination_address_prefix                  = "*"
      destination_address_prefixes                = null
      destination_application_security_group_ids  = null
      access                                      = "Allow"
      priority                                    = 100
      direction                                   = "Inbound"
    },
  #--------------------------------------------------------------------------
  # cs-NSG-wfe
  #--------------------------------------------------------------------------
    {
      nsgName                                     = "cs-wfe-nsg"
      name                                        = "Allow_1433_out"
      description                                 = null
      protocol                                    = "TCP"
      source_port_range                           = "*"
      source_port_ranges                          = null
      destination_port_range                      = "1433"
      destination_port_ranges                     = null
      source_address_prefix                       = "*"
      source_address_prefixes                     = null
      source_application_security_group_ids       = null
      destination_address_prefix                  = "10.10.10.32/27"
      destination_address_prefixes                = null
      destination_application_security_group_ids  = null
      access                                      = "Allow"
      priority                                    = 100
      direction                                   = "Outbound"
    },
    {
      nsgName                                     = "cs-wfe-nsg"
      name                                        = "Allow_11-11999_out"
      description                                 = null
      protocol                                    = "TCP"
      source_port_range                           = "*"
      source_port_ranges                          = null
      destination_port_range                      = "11000-11999"
      destination_port_ranges                     = null
      source_address_prefix                       = "*"
      source_address_prefixes                     = null
      source_application_security_group_ids       = null
      destination_address_prefix                  = "10.10.10.32/27"
      destination_address_prefixes                = null
      destination_application_security_group_ids  = null
      access                                      = "Allow"
      priority                                    = 110
      direction                                   = "Outbound"
    },
    {
      nsgName                                     = "cs-wfe-nsg"
      name                                        = "Allow_HTTP_In"
      description                                 = null
      protocol                                    = "TCP"
      source_port_range                           = "*"
      source_port_ranges                          = null
      destination_port_range                      = "80"
      destination_port_ranges                     = null
      source_address_prefix                       = "*"
      source_address_prefixes                     = null
      source_application_security_group_ids       = null
      destination_address_prefix                  = "10.10.10.0/27"
      destination_address_prefixes                = null
      destination_application_security_group_ids  = null
      access                                      = "Allow"
      priority                                    = 100
      direction                                   = "Inbound"
    }
  ]
}