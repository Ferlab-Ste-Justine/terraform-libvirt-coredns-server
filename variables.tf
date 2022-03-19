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

variable "ip" {
  description = "Ip address of the vm if a libvirt network is selected"
  type        = string
  default     = ""
}

variable "mac" {
  description = "Mac address of the vm if a libvirt network is selected"
  type        = string
  default     = ""
}

variable "macvtap_interfaces" {
  description = "List of macvtap interfaces. Mutually exclusive with the network_id, ip and mac fields. Each entry has the following keys: interface, prefix_length, ip, mac, gateway and dns_servers"
  type        = list(any)
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

variable "etcd_ca_certificate" {
  description = "Tls ca certificate that will be used to validate the authenticity of the backend's server certificate"
  type        = string
}

variable "etcd_client_certificate" {
  description = "Tls client certificate to connect to the etcd backend"
  type        = string
}

variable "etcd_client_key" {
  description = "Tls client key to connect to the etcd backend"
  type        = string
  sensitive   = true
}

variable "etcd_key_prefix" {
  description = "Key prefix to use to identify the dns zonefiles in etcd"
  type        = string
}

variable "etcd_endpoints" {
  description = "Endpoints of the etcd servers, taking the <ip>:<port> format"
  type        = list(string)
}

variable "zonefiles_reload_interval" {
  description = "Interval of time the coredns auto module waits to check for zonefiles refresh"
  type        = string
  default     = "3s"
}

variable "load_balance_records" {
  description = "Whether to randomize the order of A and AAAA records in the answer"
  type        = bool
  default     = true
}

variable "alternate_dns_servers" {
  description = "Dns servers to use to answer all queries that are not covered by the zonefiles."
  type        = list(string)
  default     = []
}