advertise_addr = "10.0.0.40"
datacenter = "dc1"
client_addr = "0.0.0.0"
addresses {
  dns = "0.0.0.0"
  http = "0.0.0.0"
}
ports {
  dns = 53
  http = 8500
}
recursors = ["8.8.8.8", "8.8.4.4"]
raft_protocol = 3
disable_update_check = true
disable_host_node_id = true
