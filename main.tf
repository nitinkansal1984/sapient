module "rg" {
 source = "./modules/rg"
}


module "network" {
 source = "./modules/network"
 rgname = module.rg.rgname
}

module "lb" {
 source = "./modules/lb"
 rgname = module.rg.rgname
 public_ip_address_id = module.network.public_ip_address_id
}


module "nsg" {
  source = "./modules/nsg"
  rgname = module.rg.rgname
  nsg_rules = var.nsg_rules
}

resource "tls_private_key" "sap_ssh" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "azurerm_linux_virtual_machine_scale_set" "linux_vmss" {
  instances           = var.instances_count
  location            = var.location
  name                = "myvmss"
  resource_group_name = module.rg.rgname
  sku                 = var.vms_size
  depends_on          = [module.lb.lbrule]

  admin_username                   = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = "demouser"
    public_key = tls_private_key.sap_ssh.public_key_openssh
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
    network_security_group_id                    = module.nsg.nsgid
    ip_configuration {
      name                                         = "myipconfig"
      primary                                      = true
      subnet_id                                    = module.network.subnet_id
      load_balancer_backend_address_pool_ids       = ["${module.lb.bpepoolid}"]
    }
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

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
  triggers = {
    always_run = "${timestamp()}"
  }
  provisioner "local-exec" {
      command = <<EOT
        uname -a;
        echo '${tls_private_key.sap_ssh.private_key_openssh}' > /tmp/mykey.pem;
        chmod 400 /tmp/mykey.pem;
        /bin/sudo apt-get update -y; /bin/sudo apt-get install python3;
        /bin/sudo apt-get install ansible -y;
        ANSIBLE_HOST_KEY_CHECKING=False /bin/sudo ansible-playbook --user "demouser" -i '${module.network.publicip},' --private-key /tmp/mykey.pem  -e ansible_ssh_port=${each.value} apache.yml;
#        rm -rf /tmp/mykey.pem; 
    EOT
  }
}

output "URL" {
  value = "http://${module.network.publicip}"
}
