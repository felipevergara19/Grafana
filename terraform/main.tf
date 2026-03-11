terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "2.5.2"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

variable "linode_token" {
  type      = string
  sensitive = true
}

variable "instance_id" {
  type        = string
  description = "El ID de tu Linode actual"
}

# Ejemplo: Manejar el Firewall desde Terraform
resource "linode_firewall" "grafana_firewall" {
  label = "grafana-stack-firewall"

  inbound {
    label    = "allow-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = ["0.0.0.0/0"]
  }

  inbound {
    label    = "allow-https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = ["0.0.0.0/0"]
  }

  inbound {
    label    = "allow-ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = ["0.0.0.0/0"] # Recomendado: limitar a tu IP
  }

  inbound_policy = "DROP"
  outbound_policy = "ACCEPT"

  # Vincular al Linode existente
  linodes = [tonumber(var.instance_id)]
}
