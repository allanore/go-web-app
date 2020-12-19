###################################################
# Resource Group Variables
###################################################

variable "rgName" {
  type    = string
  default = "cloudskills-IaaS-rg"
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

variable "sharedServicesRgName" {
  type    = string
  default = "cloudSkills-sharedServices-rg"
}

###################################################
# KeyVault Variables
###################################################

variable "keyVaultName" {
  type    = string
  default = "cloudSkillsDemo-kv"
}

variable "Rg" {
  type    = string
  default = "cloudSkills-sharedServices-rg"
}

variable "vmPwdName" {
  type    = string
  default = "wfe-VM-Pwd"
}

variable "sqlPwdName" {
  type    = string
  default = "DB-Pwd"
}

###################################################
# Vnet Variables
###################################################

variable "vnetName" {
  type    = string
  default = "csDemoVnet"
}


variable "subnetName" {
  type    = string
  default = "csWFE_10.10.10.0_27"
}

###################################################
# LAWS Variables
###################################################

variable "updateMgmtLaw" {
  type    = map(string)
  default = {
    name    = "cloudSkillsDemo-la"
    rg_name = "cloudSkills-sharedServices-rg"
  }
}


###################################################
# VM Variables
###################################################

variable "userName" {
  type    = string
  default = "wfeadmin"
}

variable "linuxVMs" {
  type = list(object({
    name              = string
    sku               = string
    diskType          = string
    priority          = string 
    image_publisher   = string
    image_offer       = string
    image_sku         = string
    image_version     = string
    tags              = map(string)
  }))
  default = [
    {
      name              = "wfeVM01"
      sku               = "Standard_D1_v2"
      diskType          = "premium_ssd"
      priority          = "Spot"
      image_publisher   = "Canonical"
      image_offer       = "UbuntuServer"
      image_sku         = "18.04-LTS"
      image_version     = "18.04.201910210"
      tags              = {
        Owner           = "Bob"
        Env             = "Prod"
        UpdateGroup     = "Phase1"
        DisableUpdates  = "False"
        Environment     = "Demo Lab"
        StopResources   = "Yes"
      } 
    },
    {
      name              = "wfeVM02"
      sku               = "Standard_D1_v2"
      diskType          = "premium_ssd"
      priority          = "Spot"
      image_publisher   = "Canonical"
      image_offer       = "UbuntuServer"
      image_sku         = "18.04-LTS"
      image_version     = "18.04.201910210"
      tags              = {
        Owner           = "Bob"
        Env             = "Prod"
        UpdateGroup     = "Phase2"
        DisableUpdates  = "False"
        Environment     = "Demo Lab"
        StopResources   = "Yes"
      } 
    },
  ]
}


variable "windowsVMs" {
  type = list(object({
    name              = string
    sku               = string
    diskType          = string
    priority          = string 
    image_publisher   = string
    image_offer       = string
    image_sku         = string
    image_version     = string
    tags              = map(string)
  }))
  default = [
    #     {
    #   name              = "prdVM03-Win19"
    #   sku               = "standard_d1_v2"
    #   diskType          = "premium_ssd"
    #   priority          = "Spot"
    #   image_publisher   = "MicrosoftWindowsServer"
    #   image_offer       = "WindowsServer"
    #   image_sku         = "2019-Datacenter"
    #   image_version     = "2019.0.20181107"
    #   tags              = {
    #     Owner           = "JoeFecht"
    #     Exception       = "Yes"
    #     Env             = "Prod"
    #     UpdateGroup     = "Phase3"
    #     DisableUpdates  = "False"
    #     Environment     = "Ahead - Azure Lab - Internal"
    #     StopResources   = "Yes"
    #   } 
    # },
  ]
}

###################################################
# SQL Variables
###################################################

variable "sqlSvrName" {
  default = "cssqlsvr123"
}

variable "sqlSvrVersion" {
  default = "12.0"
}

variable "sqlSvrUsername" {
  default = "dbadmin"
}

variable "sqlDbName" {
  default = "cssqldb123"
}

variable "sqlDbEdition" {
  default = "Basic"
}