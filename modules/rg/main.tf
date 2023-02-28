locals {
  tags = {
    environment = "prod"
    department = "sapient"
    source = "terraform"
  }
}

resource "random_string" "sapid" {
  length = 4
  upper = false
  special = false
  lower  = true
}

resource "azurerm_resource_group" "saprg" {
 name     = "mysap2802${random_string.sapid.id}"
 location = var.location
}

output "rgname" {
 value = azurerm_resource_group.saprg.name
}
