# Creating the Resources (Droplet)
resource "digitalocean_droplet" "lemp-stack-droplet" {
  image    = "ubuntu-18-04-x64"
  name     = "lemp-stack-droplet"
  region   = "sfo2"
  size     = "512mb"
  ssh_keys = [var.ssh_fingerprint]
}

# Creating the Load balancer that points to our lemp droplet.

resource "digitalocean_loadbalancer" "lemp-lb" {
  name   = "lemp-lb"
  region = "sfo2"


  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 80
    target_protocol = "http"
  }

   healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_ids = [
    digitalocean_droplet.lemp-stack-droplet.id
  ]

}

# create a firewall that only accepts port 80 traffic from the load balancer
resource "digitalocean_firewall" "demo-firewall" {
  name = "demo-firewall"

  droplet_ids = [
    digitalocean_droplet.lemp-stack-droplet.id
  ]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]
  }
  inbound_rule {
    protocol                  = "tcp"
    port_range                = "80"
    source_load_balancer_uids = [digitalocean_loadbalancer.lemp-lb.id]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0"]
  }
}

# create an ansible inventory file on our Ansible Folder
resource "null_resource" "ansible-provision" {
  depends_on = [
    digitalocean_droplet.lemp-stack-droplet
  ]

  provisioner "local-exec" {
    command = "echo '${digitalocean_droplet.lemp-stack-droplet.name} ansible_host=${digitalocean_droplet.lemp-stack-droplet.ipv4_address} ansible_ssh_user=root ansible_python_interpreter=/usr/bin/python3' > Ansible/inventory"
  }
}

# output the load balancer ip
output "ip" {
  value = digitalocean_loadbalancer.lemp-lb.ip
}

