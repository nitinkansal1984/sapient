resource "azurerm_lb" "saplb" {
 name                = "saplb"
 location            = var.location
 resource_group_name = var.rgname
 sku = "Standard"
 frontend_ip_configuration {
   name                 = "PublicIPAddress"
   public_ip_address_id = var.public_ip_address_id
 }

}

resource "azurerm_lb_backend_address_pool" "bpepool" {
 loadbalancer_id     = azurerm_lb.saplb.id
 name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "sapprobe" {
 loadbalancer_id     = azurerm_lb.saplb.id
 name                = "http-running-probe"
 port                = "8080"
}

resource "azurerm_lb_rule" "lbrule" {
   loadbalancer_id                = azurerm_lb.saplb.id
   name                           = "http"
   protocol                       = "Tcp"
   frontend_port                  = 80
   backend_port                   = 8080
   backend_address_pool_ids        = ["${azurerm_lb_backend_address_pool.bpepool.id}"]
   frontend_ip_configuration_name = "PublicIPAddress"
   probe_id                       = azurerm_lb_probe.sapprobe.id
}

resource "azurerm_lb_nat_rule" "lbnatrule" {
  resource_group_name            = var.rgname
  loadbalancer_id                = azurerm_lb.saplb.id
  name                           = "SSHAccess"
  protocol                       = "Tcp"
  frontend_port_start            = 2000
  frontend_port_end              = 2005
  backend_port                   = 22
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
  frontend_ip_configuration_name = "PublicIPAddress"
}

output "bpepoolid" {
  value = azurerm_lb_backend_address_pool.bpepool.id
}

output "lbrule" {
  value = azurerm_lb_rule.lbrule.id
}
