terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.44.1"
    }
  }
  backend "azurerm" {
  }    
}

provider "azurerm" {
   features {}
  }
  # Configuration options
