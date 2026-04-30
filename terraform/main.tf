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

variable "allowed_http_ips" {
  type        = list(string)
  description = "IPs permitidas para puerto 80 (HTTP)"
}

variable "allowed_https_ips" {
  type        = list(string)
  description = "IPs permitidas para puerto 443 (HTTPS)"
}

variable "allowed_ssh_ips" {
  type        = list(string)
  description = "IPs permitidas para puerto 22 (SSH)"
}


# Ejemplo: Manejar el Firewall desde Terraform
resource "linode_firewall" "grafana_firewall" {
  label = "grafana-stack-firewall"

  inbound {
    label    = "allow-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = var.allowed_http_ips
  }

  inbound {
    label    = "allow-https"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "443"
    ipv4     = var.allowed_https_ips
  }

  inbound {
    label    = "allow-ssh"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22"
    ipv4     = var.allowed_ssh_ips # Recomendado: limitar a tu IP
  }

  inbound_policy = "DROP"
  outbound_policy = "ACCEPT"

  # Vincular al Linode existente
  linodes = [tonumber(var.instance_id)]
}
