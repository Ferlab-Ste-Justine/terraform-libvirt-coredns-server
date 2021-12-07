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

variable "network_id" {
  description = "Id of the libvirt network to connect the vm to if you plan on connecting the vm to a libvirt network"
  type        = string
  default     = ""
}

variable "macvtap_interface" {
  description = "Interface that you plan to connect your vm to via a lower macvtap interface. Note that either this or network_id should be set, but not both."
  type        = string
  default     = ""
}

variable "macvtap_vm_interface_name_match" {
  description = "Expected pattern of the network interface name in the vm."
  type        = string
  //https://github.com/systemd/systemd/blob/main/src/udev/udev-builtin-net_id.c#L932
  default     = "en*"
}

variable "macvtap_subnet_prefix_length" {
  description = "Length of the subnet prefix (ie, the yy in xxx.xxx.xxx.xxx/yy). Used for macvtap only."
  type        = string
  default     = ""
}

variable "macvtap_gateway_ip" {
  description = "Ip of the physical network's gateway. Used for macvtap only."
  type        = string
  default     = ""
}

variable "macvtap_dns_servers" {
  description = "Ip of dns servers to setup on the vm, useful mostly during the initial cloud-init bootstraping to resolve domain of installables. Used for macvtap only."
  type        = list(string)
  default     = []
}

variable "ip" {
  description = "Ip address of the vm"
  type        = string
}

variable "mac" {
  description = "Mac address of the vm"
  type        = string
  default     = ""
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
  default     = ""
}

variable "ssh_admin_public_key" {
  description = "Public ssh part of the ssh key the admin will be able to login as"
  type        = string
}

variable "etcd_ca_certificate" {
  description = "Tls ca certificate that will be used to validate the authenticity of the backend's server certificate"
  type = string
}

variable "etcd_client_certificate" {
  description = "Tls client certificate to connect to the etcd backend"
  type = string
}

variable "etcd_client_key" {
  description = "Tls client key to connect to the etcd backend"
  type = string
}

variable "etcd_key_prefix" {
  description = "Key prefix to use to identify the dns zonefiles in etcd"
  type = string
}

variable "etcd_endpoints" {
  description = "Endpoints of the etcd servers, taking the <ip>:<port> format"
  type = list(string)
}

variable "coredns_version" {
  description = "Version of coredns to use"
  type = string
  default = "1.8.6"
}

variable "zonefiles_reload_interval" {
  description = "Interval of time the coredns auto module waits to check for zonefiles refresh"
  type = string
  default = "3s"
}

variable "load_balance_records" {
  description = "Whether to randomize the order of A and AAAA records in the answer"
  type = bool
  default = true
}