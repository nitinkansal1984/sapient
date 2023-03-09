resource "azurerm_virtual_network" "sapvnet" {
 name                = "sapvnet"
 address_space       = ["10.0.0.0/16"]
 location            = var.location
 resource_group_name = var.rgname
}

resource "azurerm_subnet" "sapsubnet" {
 name                 = "sapsubnet"
 resource_group_name  = var.rgname
 virtual_network_name = azurerm_virtual_network.sapvnet.name
 address_prefixes       = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "sappubip" {
 name                         = "sap-public-ip"
 sku                          = "Standard"
 location                     = var.location
 resource_group_name          = var.rgname
 allocation_method            = "Static"
 domain_name_label            = "mypublicipsap090323"
}

output "public_ip_address_id" {
  value = azurerm_public_ip.sappubip.id
}

output "subnet_id" {
  value = azurerm_subnet.sapsubnet.id
}

output "publicip" {
  value = azurerm_public_ip.sappubip.ip_address
}
