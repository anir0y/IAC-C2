resource "digitalocean_ssh_key" "c2-key" { #change c2-key to your key name
  name       = "SSH"
  public_key = "${file("~/.ssh/id_rsa.pub")}" #Change to your pub key path
}

resource "digitalocean_droplet" "covenant-c2" {
    image = "ubuntu-18-04-x64"
    name = "covenant-c2"
    region = "blr1"
    size = "s-1vcpu-1gb"
    private_networking = true
    ssh_keys = ["${digitalocean_ssh_key.c2-key.fingerprint}"] #change the name here too

connection {
      host = self.ipv4_address
      user = "root"
      type = "ssh"
      private_key = "${file("~/.ssh/id_rsa")}"  #Change to your priv. key path
      timeout = "2m"
}

 provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install docker
      "sudo curl -sSL https://get.docker.com/ | sh",
      "sudo apt install -y git",
      "git clone --recurse-submodules https://github.com/cobbr/Covenant",
      "docker build -t covenant /root/Covenant/Covenant/",
      "docker run -d -p 7443:7443 -p 80:80 -p 443:443 --name covenant -v /root/Covenant/Covenant/Data/:/app/Data covenant"
    ]
  }
}

resource "digitalocean_droplet" "covenant-c2-redir" {  #Creating a redirector
    image = "ubuntu-18-04-x64"
    name = "covenant-c2-redir"
    region = "blr1"
    size = "s-1vcpu-1gb"
    private_networking = true
    ssh_keys = ["${digitalocean_ssh_key.c2-key.fingerprint}"] #change the name here too

connection {
      host = self.ipv4_address
      user = "root"
      type = "ssh"
      private_key = "${file("~/.ssh/id_rsa")}" #Change to your priv. key path
      timeout = "2m"
}

 provisioner "remote-exec" {
    inline = [
        "export PATH=$PATH:/usr/bin",
      "wget http://archive.ubuntu.com/ubuntu/pool/main/s/socat/socat_1.7.3.2-2ubuntu2_amd64.deb", #Downloading socat from ubuntu archive
      "dpkg -i /root/socat_1.7.3.2-2ubuntu2_amd64.deb", #installing socat
      "tmux new-session -d -s socat-redir socat TCP4-LISTEN:80,fork TCP4:${digitalocean_droplet.covenant-c2.ipv4_address}:80" #Creating a tmux session for debugging
    ]
  }
}

resource "digitalocean_firewall" "covenant-c2-redir" {
    name = "portredir"

  droplet_ids = ["${digitalocean_droplet.covenant-c2-redir.id}"]

  inbound_rule {
      protocol           = "tcp"
      port_range         = "22"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
      protocol           = "tcp"
      port_range         = "80"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
      protocol           = "tcp"
      port_range         = "443"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
      protocol                = "tcp"
      port_range              = "53"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
      protocol                = "tcp"
      port_range              = "443"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
  }
    outbound_rule {
        protocol                = "tcp"
        port_range              = "80"
        destination_addresses   = ["0.0.0.0/0", "::/0"]
    }
  outbound_rule {
      protocol                = "udp"
      port_range              = "53"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_firewall" "covenant-c2" {
    name = "portforwarding"

  droplet_ids = ["${digitalocean_droplet.covenant-c2.id}"]

  inbound_rule {
      protocol           = "tcp"
      port_range         = "22"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
      protocol           = "tcp"
      port_range         = "7443"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
      protocol           = "tcp"
      port_range         = "80"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
      protocol           = "tcp"
      port_range         = "443"
      source_addresses   = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
      protocol                = "tcp"
      port_range              = "53"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
  }
  outbound_rule {
      protocol                = "tcp"
      port_range              = "443"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
  }
    outbound_rule {
        protocol                = "tcp"
        port_range              = "80"
        destination_addresses   = ["0.0.0.0/0", "::/0"]
    }
  outbound_rule {
      protocol                = "udp"
      port_range              = "53"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
      protocol                = "icmp"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
  }
}