variable "saprg" {
  description = "Name of the resource group."
  type        = string
  default     = "mysaprg"
}

variable "sapsa" {
  description = "Name of the storage account"
  type        = string
  default     = "mysapstorageact280222"
}

variable "location" {
  description = "Azure region to use."
  type        = string
  default     = "eastus"
}


variable "environment" {
  description = "Project environment."
  type        = string
  default     = "poc"
}



variable "ssh_private_key" {
  description = "Private SSH key deployed on Scale set."
  type        = string
  default     = null
}

variable "ssh_public_key" {
  description = "Public SSH key deployed on Scale set."
  type        = string
  default     = null
}

variable "accelerated_networking" {
  description = "Whether to enable accelerated networking or not."
  type        = bool
  default     = true
}

variable "dns_servers" {
  description = "List of DNS servers."
  type        = list(string)
  default     = []
}

variable "ip_forwarding_enabled" {
  description = "Whether IP forwarding is enabled on this NIC."
  type        = bool
  default     = false
}

variable "network_security_group_id" {
  description = "ID of the Network Security Group."
  type        = string
  default     = null
}


variable "application_gateway_backend_address_pool_ids" {
  description = "List of references to backend address pools of Application Gateways. A Scale Set can reference backend address pools of one Application Gateway."
  type        = list(string)
  default     = []
}

variable "load_balancer_backend_address_pool_ids" {
  description = "List of references to backend address pools of Load Balancers. A Scale Set can reference backend address pools of one public and one internal Load Balancer."
  type        = list(string)
  default     = []
}

variable "load_balancer_inbound_nat_rules_ids" {
  description = "List of references to inbound NAT rules for Load Balancers."
  type        = list(string)
  default     = []
}

variable "application_security_group_ids" {
  description = "IDs of Application Security Group IDs (up to 20)."
  type        = list(string)
  default     = []
}

variable "vms_size" {
  description = "Size (SKU) of Virtual Machines in a Scale Set."
  type        = string
}

variable "os_disk_managed_disk_type" {
  description = "Type of managed disk to create [Possible values : Standard_LRS, StandardSSD_LRS or Premium_LRS]."
  type        = string
  default     = "StandardSSD_LRS"
}

variable "os_disk_caching" {
  description = "OS disk caching requirements [Possible values : None, ReadOnly, ReadWrite]."
  type        = string
  default     = "None"
}

variable "os_disk_size_gb" {
  description = "Size of the OS disk in GB."
  type        = number
  default     = 32
}

variable "os_ephemeral_disk_enabled" {
  description = "Whether OS disk is local ephemeral disk. See https://learn.microsoft.com/en-us/azure/virtual-machines/ephemeral-os-disks."
  type        = bool
  default     = true
}

variable "os_ephemeral_disk_placement" {
  description = "Placement for the local ephemeral disk. Value can be `CacheDisk` or `ResourceDisk`. See https://learn.microsoft.com/en-us/azure/virtual-machines/ephemeral-os-disks."
  type        = string
  default     = "ResourceDisk"
}

variable "os_disk_encryption_set_id" {
  description = "ID of the Disk Encryption Set which should be used to encrypt the OS disk."
  type        = string
  default     = null
}

variable "os_disk_write_accelerator_enabled" {
  description = "Whether to enable write accelerator for the OS disk."
  type        = bool
  default     = false
}

variable "automatic_os_upgrade" {
  description = "Whether if automatic OS patches can be applied by Azure to your Scale Set. This is particularly useful when upgrade_policy_mode is set to Rolling."
  type        = bool
  default     = false
}

variable "disable_automatic_rollback" {
  description = "Disable automatic rollback in case of failures."
  type        = bool
  default     = false
}

variable "rolling_upgrade_policy" {
  description = "Rolling upgrade policy, only applicable when the upgrade_policy_mode is Rolling."
  type = object({
    max_batch_instance_percent              = number
    max_unhealthy_instance_percent          = number
    max_unhealthy_upgraded_instance_percent = number
    pause_time_between_batches              = string
  })
  default = {
    max_batch_instance_percent              = 25
    max_unhealthy_instance_percent          = 25
    max_unhealthy_upgraded_instance_percent = 25
    pause_time_between_batches              = "PT30S"
  }
}

variable "automatic_instance_repair" {
  description = "Whether to enable automatic instance repair. Must have health_probe_id or an Application Health Extension."
  type        = bool
  default     = false
}

variable "health_probe_id" {
  description = "Specifies the identifier for the Load Balancer health probe. Required when using Rolling as your upgrade_policy_mode."
  type        = string
  default     = null
}

variable "boot_diagnostics_storage_uri" {
  description = "Blob endpoint for the Storage Account to hold the Virtual Machines diagnostic files."
  type        = string
  default     = ""
}

variable "extensions" {
  description = "Extensions to add to the Scale Set."
  type = list(object({
    name                        = string
    publisher                   = string
    type                        = string
    type_handler_version        = string
    auto_upgrade_minor_version  = optional(bool, true)
    automatic_upgrade_enabled   = optional(bool, false)
    failure_suppression_enabled = optional(bool, false)
    force_update_tag            = optional(string, null)
    protected_settings          = optional(string, null)
    provision_after_extensions  = optional(list(string), [])
    settings                    = optional(string, null)
  }))
  default = []
}

variable "data_disks" {
  description = "Data disks profiles to attach."
  type = list(object({
    name                      = string
    lun                       = number
    disk_size_gb              = optional(number, null)
    create_option             = optional(string, "Empty")
    caching                   = optional(string, "None")
    storage_account_type      = optional(string, "StandardSSD_LRS")
    disk_encryption_set_id    = optional(string, null)
    disk_iops_read_write      = optional(string, null)
    disk_mbps_read_write      = optional(string, null)
    write_accelerator_enabled = optional(string, null)
  }))
  default = []
}

variable "ultra_ssd_enabled" {
  description = "Whether UltraSSD_LRS storage account type can be enabled."
  type        = bool
  default     = false
}

variable "admin_username" {
  description = "Username of the administrator account of the Virtual Machines."
  type        = string
}

variable "admin_password" {
  description = "Password for the administrator account of the Virtual Machines."
  type        = string
  default     = "ILoveIndia@2020"
}

variable "instances_count" {
  description = "Number of instances in the Scale Set."
  type        = number
  default     = 2
}

variable "source_image_reference" {
  description = "Virtual Machines source image reference."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = null
}

variable "source_image_id" {
  description = "ID of the Virtual Machines image to use."
  type        = string
  default     = null
}

variable "custom_data" {
  description = "The Base64-Encoded Custom Data which should be used for this Virtual Machine Scale Set."
  type        = string
  default     = null
}

variable "user_data" {
  description = "The Base64-Encoded User Data which should be used for this Virtual Machine Scale Set."
  type        = string
  default     = null
}

variable "scale_in_policy" {
  description = "The scale-in policy rule that decides which Virtual Machines are chosen for removal when a Virtual Machine Scale Set is scaled in. Possible values for the scale-in policy rules are Default, NewestVM and OldestVM, defaults to Default."
  type        = string
  default     = "Default"
}

variable "scale_in_force_deletion" {
  description = "Whether the Virtual Machines chosen for removal should be force deleted when the Virtual Machine Scale Set is being scaled-in."
  type        = bool
  default     = false
}

variable "overprovision" {
  description = "Should Azure over-provision Virtual Machines in this Scale Set? This means that multiple Virtual Machines will be provisioned and Azure will keep the instances which become available first - which improves provisioning success rates and improves deployment time."
  type        = bool
  default     = true
}

variable "upgrade_mode" {
  description = "Specifies how Upgrades (e.g. changing the Image/SKU) should be performed to Virtual Machine Instances. Possible values are Automatic, Manual and Rolling. Defaults to Manual."
  type        = string
  default     = "Manual"
}

variable "zone_balancing_enabled" {
  description = "Whether the Virtual Machines in this Scale Set should be strictly evenly distributed across Availability Zones? Changing this forces a new resource to be created."
  type        = bool
  default     = true
}

variable "zones_list" {
  description = "A list of Availability Zones in which the Virtual Machines in this Scale Set should be created in. Changing this forces a new resource to be created."
  type        = list(number)
  default     = [1, 2, 3]
}

variable "identity" {
  description = "Identity block information as described here https://www.terraform.io/docs/providers/azurerm/r/linux_virtual_machine_scale_set.html#identity."
  type = object({
    type         = string
    identity_ids = list(string)
  })
  default = null
}

variable "nsg_rules" {
  type = list(object({
    name = string
    priority = number
    direction = string
    access = string
    protocol = string
    source_port_range = string
    destination_port_range = string
    source_address_prefix = string
    destination_address_prefix = string
}))

}
