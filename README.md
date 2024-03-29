# About

This module provision coredns instances on kvm.

The server is configured to to work with zonefiles which are fetched from an etcd cluster. Each domain is a key in etcd (with an optional prefix) and the zonefile (which should be compatible with the auto plugin) is the value.

The server will automatically detect any changes in the domains in the etcd backend and update the zonefiles accordingly.

Note that except for updates to zonefiles, the coredns server is decoupled from the etcd cluster and will happily keep answering dns requests with whatever zonefiles it has on hand (they just won't update until the etcd cluster is back up).

# Note About Alternatives

Coredns also has a SkyDNS compatible plugin: https://coredns.io/plugins/etcd/

Some of the perceived pros of the above plugin:
- Assuming that the cache plugin isn't used (ie, all dns requests hit etcd), the consistency level of the answer from different dns servers shortly after the change can't be matched
- From what I read in the readme, decentralisation of ip registration seems better supported out of the box (you could support it with zonefiles too, but extra logic would have to be added using something like templates)

Some of the perceived pros of our implementation:
- Full support for zonefiles to the extend the coredns auto plugin supports them (ie, fewer quirks)
- Decent consistency/performance tradeoff: The server does a watch for changes on the etcd cluster (but will not put any more stress than that etcd) and will automatically update its local zonefiles with changes. The refresh interval set in the auto plugin will determine how quickly those changes will be picked up (3 seconds by default)
- Greater decoupling from etcd: The server is only dependent on etcd for updating zonefiles. If etcd is down, it can still answer queries with the zonefiles it has. 

# Related Projects

See the following terraform module that uploads very basic zonefiles in etcd: https://github.com/Ferlab-Ste-Justine/etcd-zonefile

Also, this module expects to authentify against etcd using tls certificate authentication. The following terraform module will, taking a certificate authority as input, generate a valid key and certificate for a given etcd user (disregard the openstack in the name): https://github.com/Ferlab-Ste-Justine/etcd-client-certificate

# Supported Networking

The module supports libvirt networks and macvtap (bridge mode).

# Usage

## Input

- **name**: Name of the vm
- **vcpus**: Number of vcpus to assign to the vm. Defaults to 2.
- **memory**: Amount of memory in MiB to assign to the vm. Defaults to 8192 (ie, 8 GiB).
- **volume_id**: Id of the image volume to attach to the vm. A recent version of ubuntu is recommended as this is what this module has been validated against.
- **libvirt_network**: Parameters to connect to libvirt networks. Note that while the server will bind on all interfaces for dns resolution, the health endpoint and prometheus metrics will only be exposed on the first interface, including macvtap interfaces. Each entry has the following keys:
  - **network_id**: Id (ie, uuid) of the libvirt network to connect to (in which case **network_name** should be an empty string).
  - **network_name**: Name of the libvirt network to connect to (in which case **network_id** should be an empty string).
  - **ip**: Ip of interface connecting to the libvirt network.
  - **mac**: Mac address of interface connecting to the libvirt network.
  - **prefix_length**:  Length of the network prefix for the network the interface will be connected to. For a **192.168.1.0/24** for example, this would be **24**.
  - **gateway**: Ip of the network's gateway. Usually the gateway the first assignable address of a libvirt's network.
  - **dns_servers**: Dns servers to use. Usually the dns server is first assignable address of a libvirt's network.
- **macvtap_interfaces**: List of macvtap interfaces to connect the vm to if you opt for macvtap interfaces. Note that while the server will bind on all interfaces for dns resolution, the health endpoint and prometheus metrics will only be exposed on the first interface, including libvirt networks. Each entry in the list is a map with the following keys:
  - **interface**: Host network interface that you plan to connect your macvtap interface with.
  - **prefix_length**: Length of the network prefix for the network the interface will be connected to. For a **192.168.1.0/24** for example, this would be 24.
  - **ip**: Ip associated with the macvtap interface. 
  - **mac**: Mac address associated with the macvtap interface
  - **gateway**: Ip of the network's gateway for the network the interface will be connected to.
  - **dns_servers**: Dns servers for the network the interface will be connected to. If there aren't dns servers setup for the network your vm will connect to, the ip of external dns servers accessible accessible from the network will work as well.
- **cloud_init_volume_pool**: Name of the volume pool that will contain the cloud-init volume of the vm.
- **cloud_init_volume_name**: Name of the cloud-init volume that will be generated by the module for your vm. If left empty, it will default to ```<name>-cloud-init.iso```.
- **ssh_admin_user**: Username of the default sudo user in the image. Defaults to **ubuntu**.
- **admin_user_password**: Optional password for the default sudo user of the image. Note that this will not enable ssh password connections, but it will allow you to log into the vm from the host using the **virsh console** command.
- **ssh_admin_public_key**: Public part of the ssh key the admin will be able to login as
- **etcd**: Parameters to connect to the etcd backend. It has the following keys:
  - **ca_certificate**: Tls ca certificate that will be used to validate the authenticity of the etcd cluster
  - **key_prefix**: Prefix for all the domain keys. The server will look for keys with this prefix and will remove this prefix from the key's name to get the domain.
  - **endpoints**: A list of endpoints for the etcd servers, each entry taking the ```<ip>:<port>``` format
  - **client**: Authentication parameters for the client (either certificate or username/password authentication are support). It has the following keys:
    - **certificate**: Client certificate if certificate authentication is used.
    - **key**: Client key if certificate authentication is used.
    - **username**: Client username if certificate authentication is used.
    - **password**: Client password if certificate authentication is used.
- **dns**: Parameters to customise the dns behavior. It has the following keys:
  - **zonefiles_reload_interval**: Time interval at which the **auto** plugin should poll the zonefiles for updates. Defaults to **3s** (ie, 3 seconds).
  - **load_balance_records**: In the event that an A or AAAA record yields several ips, whether to randomize the returned order or not (with clients that only take the first ip, you can achieve some dns-level load balancing this way). Defaults to **true**.
  - **alternate_dns_servers**: List of dns servers to use to answer all queries that are not covered by the zonefiles. It defaults to an empty list.
- **chrony**: Optional chrony configuration for when you need a more fine-grained ntp setup on your vm. It is an object with the following fields:
  - **enabled**: If set the false (the default), chrony will not be installed and the vm ntp settings will be left to default.
  - **servers**: List of ntp servers to sync from with each entry containing two properties, **url** and **options** (see: https://chrony.tuxfamily.org/doc/4.2/chrony.conf.html#server)
  - **pools**: A list of ntp server pools to sync from with each entry containing two properties, **url** and **options** (see: https://chrony.tuxfamily.org/doc/4.2/chrony.conf.html#pool)
  - **makestep**: An object containing remedial instructions if the clock of the vm is significantly out of sync at startup. It is an object containing two properties, **threshold** and **limit** (see: https://chrony.tuxfamily.org/doc/4.2/chrony.conf.html#makestep)
- **fluentbit**: Optional fluend configuration to securely route logs to a fluend/fluent-bit node using the forward plugin. Alternatively, configuration can be 100% dynamic by specifying the parameters of an etcd store to fetch the configuration from. It has the following keys:
  - **enabled**: If set the false (the default), fluent-bit will not be installed.
  - **coredns_tag**: Tag to assign to logs coming from coredns
  - **coredns_updater_tag**: Tag to assign to logs coming from the coredns zonefiles updater
  - **node_exporter_tag** Tag to assign to logs coming from the prometheus node exporter
  - **forward**: Configuration for the forward plugin that will talk to the external fluend/fluent-bit node. It has the following keys:
    - **domain**: Ip or domain name of the remote fluend node.
    - **port**: Port the remote fluend node listens on
    - **hostname**: Unique hostname identifier for the vm
    - **shared_key**: Secret shared key with the remote fluentd node to authentify the client
    - **ca_cert**: CA certificate that signed the remote fluentd node's server certificate (used to authentify it)
  - **etcd**: Parameters to fetch fluent-bit configurations dynamically from an etcd cluster. It has the following keys:
    - **enabled**: If set to true, configurations will be set dynamically. The default configurations can still be referenced as needed by the dynamic configuration. They are at the following paths:
      - **Global Service Configs**: /etc/fluent-bit-customization/default-config/fluent-bit-service.conf
      - **Systemd Inputs**: /etc/fluent-bit-customization/default-config/fluent-bit-inputs.conf
      - **Forward Output**: /etc/fluent-bit-customization/default-config/fluent-bit-output.conf
    - **key_prefix**: Etcd key prefix to search for fluent-bit configuration
    - **endpoints**: Endpoints of the etcd cluster. Endpoints should have the format `<ip>:<port>`
    - **ca_certificate**: CA certificate against which the server certificates of the etcd cluster will be verified for authenticity
    - **client**: Client authentication. It takes the following keys:
      - **certificate**: Client tls certificate to authentify with. To be used for certificate authentication.
      - **key**: Client private tls key to authentify with. To be used for certificate authentication.
      - **username**: Client's username. To be used for username/password authentication.
      - **password**: Client's password. To be used for username/password authentication.
- **install_dependencies**: Whether cloud-init should install external dependencies (should be set to false if you already provide an image with the external dependencies built-in).

## Example

Below is an orchestration I ran locally to troubleshoot the module.

```
module "coredns" {
  source = "git::https://github.com/Ferlab-Ste-Justine/kvm-coredns-server.git"
  name = "coredns-1"
  vcpus = 2
  memory = 8192
  volume_id = libvirt_volume.coredns.id

  macvtap_interfaces = [
      {
          interface = local.networks.lan1.interface
          prefix_length = local.networks.lan1.prefix
          gateway = local.networks.lan1.gateway
          dns_servers = local.networks.lan1.dns
          ip = data.netaddr_address_ipv4.lan1_coredns_1.address
          mac = data.netaddr_address_mac.lan1_coredns_1.address
      },
      {
          interface = local.networks.lan2.interface
          prefix_length = local.networks.lan2.prefix
          gateway = local.networks.lan2.gateway
          dns_servers = local.networks.lan2.dns
          ip = data.netaddr_address_ipv4.lan2_coredns_1.address
          mac = data.netaddr_address_mac.lan2_coredns_1.address
      }
  ]
  
  cloud_init_volume_pool = "coredns"
  ssh_admin_public_key = local.coredns_ssh_public_key
  admin_user_password = local.console_password
  etcd = {
      ca_certificate = local.etcd_ca_cert
      key_prefix = "/coredns/"
      endpoints = [for server in local.etcd.servers: "${server.ip}:2379"]
      client = {
          key = local.etcd_coredns_key
          certificate = local.etcd_coredns_cert
      }
  }
  dns = {
      alternate_dns_servers = ["8.8.8.8"]
      zonefiles_reload_interval = "3s"
      load_balance_records = true
  }
}
```

Some gotchas that apply to this project can be found here: https://github.com/Ferlab-Ste-Justine/kvm-etcd-server#gotchas