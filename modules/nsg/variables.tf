variable "location" {
  description = "Azure region to use."
  type        = string
  default     = "eastus"
}

variable "rgname" {
  type = string
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

