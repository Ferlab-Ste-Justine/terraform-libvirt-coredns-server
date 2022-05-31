variable "name" {
  description = "Name to give to the vm"
  type = string
  default = "coredns"
}

variable "vcpus" {
  description = "Number of vcpus to assign to the vm"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Amount of memory in MiB"
  type        = number
  default     = 8192
}

variable "volume_id" {
  description = "Id of the disk volume to attach to the vm"
  type        = string
}

variable "libvirt_network" {
  description = "Parameters of the libvirt network connection if a libvirt network is used. Has the following parameters: network_id, ip, mac"
  type = object({
      network_id = string
      ip = string
      mac = string
  })
  default = {
      network_id = ""
      ip = ""
      mac = ""
  }
}
variable "macvtap_interfaces" {
  description = "List of macvtap interfaces. Mutually exclusive with the network_id, ip and mac fields. Each entry has the following keys: interface, prefix_length, ip, mac, gateway and dns_servers"
  type        = list(object({
    interface = string,
    prefix_length = number,
    ip = string,
    mac = string,
    gateway = string,
    dns_servers = list(string),
  }))
  default = []
}

variable "cloud_init_volume_pool" {
  description = "Name of the volume pool that will contain the cloud init volume"
  type        = string
}

variable "cloud_init_volume_name" {
  description = "Name of the cloud init volume"
  type        = string
  default = ""
}

variable "ssh_admin_user" { 
  description = "Pre-existing ssh admin user of the image"
  type        = string
  default     = "ubuntu"
}

variable "admin_user_password" { 
  description = "Optional password for admin user"
  type        = string
  sensitive   = true
  default     = ""
}

variable "ssh_admin_public_key" {
  description = "Public ssh part of the ssh key the admin will be able to login as"
  type        = string
}

variable "etcd" {
  description = "Parameters for the etcd backend"
  type        = object({
    key_prefix = string
    endpoints = list(string)
    ca_certificate = string
    client = object({
      certificate = string
      key = string
      username = string
      password = string
    })
  })
}

variable "dns" {
  description = "Parameters for the etcd backend"
  type        = object({
    zonefiles_reload_interval = string
    load_balance_records = bool
    alternate_dns_servers = list(string)
  })
  default = {
    zonefiles_reload_interval = "3s"
    load_balance_records = true
    alternate_dns_servers = []
  }
}