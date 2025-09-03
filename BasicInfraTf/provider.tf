terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.40.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "9eb6dd3b-7d3d-4d3a-82fa-3747ca6f588e"
}
