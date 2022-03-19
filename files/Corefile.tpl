.:53 {
    #Because some distros have a localhost dns setup, we need to be picky on the interface we
    #listen to. we can't just use 0.0.0.0, it will fail.
%{ for bind_address in bind_addresses ~}
    bind ${bind_address}
%{ endfor ~}
    auto {
        directory /opt/coredns/zonefiles (.*) {1}
        reload ${reload_interval}
    }
%{ if length(alternate_dns_servers) > 0 ~}
    alternate original SERVFAIL,NXDOMAIN . ${join(" ", [for server in alternate_dns_servers: "${server}:53"])}
%{ endif ~}
%{ if load_balance_records ~}
    loadbalance round_robin
%{ endif ~}
    reload 5s
    loop
    nsid ${hostname}
    prometheus 0.0.0.0:9153
    health 0.0.0.0:8080
    errors
    log
}