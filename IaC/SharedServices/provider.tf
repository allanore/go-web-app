terraform {
  required_version = ">=0.13.0"
}

provider "azurerm" {
  version = "=2.40.0"
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
      recover_soft_deleted_key_vaults = true
    }
  }
}