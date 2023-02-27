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
 tags = local.tags
}

#resource "azurerm_storage_account" "sapsa" {
#  name                = "tfsta${random_string.sapid.id}"
#  resource_group_name = "${azurerm_resource_group.saprg.name}"

#  location     = var.location
#  account_tier             = "Standard"
#  account_replication_type = "LRS"
#}


resource "azurerm_virtual_network" "sapvnet" {
 name                = "sapvnet"
 address_space       = ["10.0.0.0/16"]
 location            = var.location
 resource_group_name = azurerm_resource_group.saprg.name
}

resource "azurerm_subnet" "sapsubnet" {
 name                 = "sapsubnet"
 resource_group_name  = azurerm_resource_group.saprg.name
 virtual_network_name = azurerm_virtual_network.sapvnet.name
 address_prefixes       = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "sappubip" {
 name                         = "sap-public-ip"
 sku                          = "Standard"
 location                     = var.location
 resource_group_name          = azurerm_resource_group.saprg.name
 allocation_method            = "Static"
 domain_name_label            = "mypublicipsapient"
}

resource "azurerm_lb" "saplb" {
 name                = "saplb"
 location            = var.location
 resource_group_name = azurerm_resource_group.saprg.name
 sku = "Standard"
 frontend_ip_configuration {
   name                 = "PublicIPAddress"
   public_ip_address_id = azurerm_public_ip.sappubip.id
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
  resource_group_name            = azurerm_resource_group.saprg.name
  loadbalancer_id                = azurerm_lb.saplb.id
  name                           = "SSHAccess"
  protocol                       = "Tcp"
  frontend_port_start            = 2000
  frontend_port_end              = 2005
  backend_port                   = 22
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_network_security_group" "sapnsg" {
  name                = "ssh-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.saprg.name
  dynamic "security_rule" {
   for_each = var.nsg_rules
   content {
    name                       = security_rule.value["name"]
    priority                   = security_rule.value["priority"]
    direction                  = security_rule.value["direction"]
    access                     = security_rule.value["access"]
    protocol                   = security_rule.value["protocol"]
    source_port_range          = security_rule.value["source_port_range"]
    destination_port_range     = security_rule.value["destination_port_range"]
    source_address_prefix      = security_rule.value["source_address_prefix"]
    destination_address_prefix = security_rule.value["destination_address_prefix"]
  }
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "linux_vmss" {
  instances           = var.instances_count
  location            = var.location
  name                = "myvmss"
  resource_group_name = azurerm_resource_group.saprg.name
  sku                 = var.vms_size
  depends_on          = [azurerm_lb_rule.lbrule]

  admin_username                   = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = "demouser"
    public_key = file("/root/.ssh/authorized_keys")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  network_interface {
    name                          = "mynic"
    primary                       = true
    network_security_group_id                    = azurerm_network_security_group.sapnsg.id
    ip_configuration {
      name                                         = "myipconfig"
      primary                                      = true
      subnet_id                                    = azurerm_subnet.sapsubnet.id
      load_balancer_backend_address_pool_ids       = ["${azurerm_lb_backend_address_pool.bpepool.id}"]
    }
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

#  dynamic "rolling_upgrade_policy" {
#    for_each = var.upgrade_mode != "Manual" ? ["Automatic"] : []
#    content {
#      max_batch_instance_percent              = lookup(var.rolling_upgrade_policy, "max_batch_instance_percent")
#      max_unhealthy_instance_percent          = lookup(var.rolling_upgrade_policy, "max_unhealthy_instance_percent")
#      max_unhealthy_upgraded_instance_percent = lookup(var.rolling_upgrade_policy, "max_unhealthy_upgraded_instance_percent")
#      pause_time_between_batches              = lookup(var.rolling_upgrade_policy, "pause_time_between_batches")
#    }
#  }

#  overprovision = var.overprovision

#  scale_in {
#    rule                   = var.scale_in_policy
#    force_deletion_enabled = var.scale_in_force_deletion
#  }

  upgrade_mode = var.upgrade_mode
  zone_balance = var.zone_balancing_enabled
  zones        = var.zones_list

}

locals {
  ports=toset(["2000", "2001"])
}

resource "null_resource" "installansible" {
  depends_on  = [azurerm_linux_virtual_machine_scale_set.linux_vmss]
  for_each = local.ports
#  triggers = {
#    always_run = "${timestamp()}"
#  }
  provisioner "local-exec" {
      command = <<EOT
        apt-get update -y;
        apt-get install ansible -y;
        ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u demouser -i '${azurerm_public_ip.sappubip.ip_address},' --private-key /root/.ssh/id_rsa -e 'pub_key=/root/.ssh/authorized_keys'  -e ansible_ssh_port=${each.value} apache.yml
    EOT
  }
}

