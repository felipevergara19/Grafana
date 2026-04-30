# Grafana Monitoring Stack

[English version below](#english-version)

![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?style=flat&logo=grafana&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat&logo=prometheus&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)
![Linode](https://img.shields.io/badge/Linode-00A95C?style=flat&logo=linode&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat&logo=github-actions&logoColor=white)

---

## 🇪🇸 Versión en Español

Stack de monitoreo e infraestructura de seguridad desplegado en producción sobre un VPS en Linode. Incluye visualización de métricas, monitoreo de seguridad con **Wazuh** (SIEM), autenticación federada con **Google OAuth** y un pipeline CI/CD con escaneo de vulnerabilidades como gate antes del deploy.

### 🏗️ Arquitectura

```
┌──────────────────────────────────────────────────────────────┐
│                        Linode VPS                            │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐  │
│  │              Linode Cloud Firewall (Terraform)         │  │
│  │   inbound: 80, 443 → ACCEPT  |  22 → IP restringida   │  │
│  │   everything else            → DROP (default-deny)     │  │
│  └────────────────────────────────────────────────────────┘  │
│                            ▼                                 │
│  ┌─────────┐    ┌──────────────────────────────────────┐     │
│  │  Caddy  │───▶│           monitor_net (bridge)       │     │
│  │ :80/443 │    │                                      │     │
│  │  HTTPS  │    │  ┌─────────┐      ┌──────────────┐   │     │
│  └─────────┘    │  │ Grafana │◀─────│  Prometheus  │   │     │
│                 │  │  :3000  │      │    :9090     │   │     │
│                 │  │ OAuth   │      └──────┬───────┘   │     │
│                 │  └─────────┘             │ scrape    │     │
│                 │                  ┌───────▼────────┐  │     │
│                 │                  │  Node Exporter │  │     │
│                 │                  │    :9100       │  │     │
│                 │                  └────────────────┘  │     │
│                 │                                      │     │
│                 │  ┌────────────┐  Datasources:        │     │
│                 │  │ Watchtower │  · Prometheus        │     │
│                 │  │ (updates)  │  · Wazuh (SIEM)      │     │
│                 │  └────────────┘  · Action1           │     │
│                 └──────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────┘
         ▲                              ▲
         │ Terraform                    │ GitHub Actions
         │ (Firewall IaC)               │ Trivy scan → SSH deploy
┌─────────────────┐            ┌──────────────────┐
│  Local machine  │            │   Push to main   │
│  terraform/     │            │   → scan → deploy│
└─────────────────┘            └──────────────────┘
```

### 🚀 Características principales

- **Grafana:** Visualización de dashboards, alertas y autenticación con Google OAuth (SSO).
- **Prometheus:** Recolección y almacenamiento de métricas (TSDB), configurado como datasource de Grafana.
- **Node Exporter:** Métricas de sistema operativo y hardware del servidor (CPU, RAM, Disco, red) cada 15s.
- **Caddy:** Proxy inverso con certificados SSL/TLS automáticos via Let's Encrypt — zero-config HTTPS.
- **Wazuh:** Datasource de SIEM integrado en Grafana para visualización de eventos de seguridad.
- **Action1:** Datasource de gestión de endpoints integrado en Grafana.
- **Watchtower:** Actualización automática de imágenes Docker cada 24 horas con limpieza de imágenes antiguas.
- **Terraform:** Firewall de Linode administrado como código — política default-deny con IPs configurables por variable.
- **CI/CD con security gate:** GitHub Actions ejecuta YAML lint + Trivy (CRITICAL/HIGH) antes de cada deploy; si el scan falla, el deploy no ocurre.

### 📁 Estructura del proyecto

```
Grafana/
├── .github/
│   └── workflows/
│       └── deploy.yml          # Pipeline: security scan → SSH deploy
├── config/
│   ├── Caddyfile               # Configuración del proxy inverso HTTPS
│   └── prometheus.yml          # Scrape configs de Prometheus
├── provisioning/
│   └── datasources/
│       └── sources.yml         # Datasources de Grafana (Prometheus, Wazuh, Action1)
├── terraform/
│   ├── main.tf                 # Firewall de Linode con variables de IP
│   └── terraform.tfvars.example
├── docker-compose.yml          # Stack completo: Caddy, Grafana, Prometheus, Node Exporter, Watchtower
├── .env.example                # Template de variables de entorno
├── .yamllint                   # Reglas de linting YAML
└── .gitignore
```

### ⚙️ Pipeline CI/CD (GitHub Actions)

Cada push a `main` ejecuta dos jobs en secuencia:

```
Push → [security_scan] YAML lint + Trivy fs scan → (solo si pasa) → [deploy] SSH deploy al VPS
```

El job `deploy` recrea el archivo `.env` desde GitHub Secrets, inyecta credenciales en los datasources de Grafana e invoca `docker compose up -d --force-recreate`. Los secretos nunca tocan el repositorio.

### 🛠 Requisitos previos

- [Docker](https://docs.docker.com/get-docker/) y [Docker Compose](https://docs.docker.com/compose/install/) instalados en el servidor.
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0 en tu máquina local.
- Un token de API de Linode para gestionar el firewall.
- Un dominio apuntando al VPS (para que Caddy genere el certificado SSL).
- Una aplicación OAuth en Google Cloud Console (para autenticación en Grafana).

### ⚙️ Instalación y Configuración

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/felipevergara19/Grafana.git
   cd Grafana
   ```

2. **Variables de entorno:**
   ```bash
   cp .env.example .env
   # Edita .env con tu dominio, credenciales de Grafana y tokens de OAuth
   ```

3. **Firewall con Terraform:**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edita terraform.tfvars: agrega tu linode_token, instance_id
   # y restringe allowed_ssh_ips a tu IP pública (/32)
   terraform init
   terraform apply
   ```

4. **Levantar el stack:**
   ```bash
   cd ..
   docker compose up -d
   ```

5. **Acceso:**
   Ingresa a `https://<TU_DOMINIO>`. Caddy provisiona el certificado SSL automáticamente en el primer arranque.

### 🔒 Consideraciones de Seguridad

- `.env` y `*.tfvars` están excluidos del repositorio via `.gitignore` — los secretos se inyectan en runtime desde GitHub Secrets.
- El firewall usa `inbound_policy = "DROP"` (default-deny); solo los puertos 80, 443 y 22 tienen reglas explícitas de aceptación.
- Las IPs permitidas para cada puerto son variables de Terraform — nunca hardcodeadas en el código fuente.
- Trivy escanea el filesystem del repositorio en cada push; vulnerabilidades CRITICAL o HIGH bloquean el deploy automáticamente.
- Grafana corre con `user: "472"` (usuario no-root dentro del contenedor).
- Todos los servicios están aislados en una red Docker interna (`monitor_net`); solo Caddy expone puertos al host.

---

<br>

<a name="english-version"></a>

## 🇬🇧 English Version

Production monitoring and security infrastructure stack deployed on a Linode VPS. Features metrics visualization, security monitoring with **Wazuh** (SIEM), federated authentication via **Google OAuth**, and a CI/CD pipeline with vulnerability scanning as a gate before every deploy.

### 🚀 Key Features

- **Grafana:** Dashboard visualization, alerting, and Google OAuth SSO authentication.
- **Prometheus:** Metrics collection and time-series database, provisioned as a Grafana datasource.
- **Node Exporter:** OS and hardware metrics (CPU, RAM, Disk, network) scraped every 15s.
- **Caddy:** Reverse proxy with automatic Let's Encrypt SSL/TLS certificates — zero-config HTTPS.
- **Wazuh:** SIEM datasource integrated into Grafana for security event visualization.
- **Action1:** Endpoint management datasource integrated into Grafana.
- **Watchtower:** Automatic Docker image updates every 24 hours with old image cleanup.
- **Terraform:** Linode firewall managed as code — default-deny policy with IP-configurable rules per variable.
- **CI/CD with security gate:** GitHub Actions runs YAML lint + Trivy (CRITICAL/HIGH) before every deploy; if the scan fails, the deploy does not proceed.

### 📁 Project Structure

```
Grafana/
├── .github/
│   └── workflows/
│       └── deploy.yml          # Pipeline: security scan → SSH deploy
├── config/
│   ├── Caddyfile               # Reverse proxy HTTPS configuration
│   └── prometheus.yml          # Prometheus scrape configs
├── provisioning/
│   └── datasources/
│       └── sources.yml         # Grafana datasources (Prometheus, Wazuh, Action1)
├── terraform/
│   ├── main.tf                 # Linode firewall with IP variables
│   └── terraform.tfvars.example
├── docker-compose.yml          # Full stack: Caddy, Grafana, Prometheus, Node Exporter, Watchtower
├── .env.example                # Environment variables template
├── .yamllint                   # YAML linting rules
└── .gitignore
```

### ⚙️ CI/CD Pipeline (GitHub Actions)

Every push to `main` runs two sequential jobs:

```
Push → [security_scan] YAML lint + Trivy fs scan → (only if passing) → [deploy] SSH deploy to VPS
```

The `deploy` job recreates the `.env` file from GitHub Secrets, injects credentials into Grafana datasources, and runs `docker compose up -d --force-recreate`. Secrets never touch the repository.

### 🛠 Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) on your server.
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0 on your local machine.
- A Linode API token to manage the firewall.
- A domain pointing to the VPS (for Caddy to issue the SSL certificate).
- A Google Cloud Console OAuth application (for Grafana authentication).

### ⚙️ Installation and Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/felipevergara19/Grafana.git
   cd Grafana
   ```

2. **Environment variables:**
   ```bash
   cp .env.example .env
   # Edit .env with your domain, Grafana credentials, and OAuth tokens
   ```

3. **Firewall with Terraform:**
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars: add your linode_token, instance_id
   # and restrict allowed_ssh_ips to your public IP (/32)
   terraform init
   terraform apply
   ```

4. **Start the stack:**
   ```bash
   cd ..
   docker compose up -d
   ```

5. **Access:**
   Navigate to `https://<YOUR_DOMAIN>`. Caddy provisions the SSL certificate automatically on first boot.

### 🔒 Security Considerations

- `.env` and `*.tfvars` are excluded from the repository via `.gitignore` — secrets are injected at runtime from GitHub Secrets.
- The firewall uses `inbound_policy = "DROP"` (default-deny); only ports 80, 443, and 22 have explicit accept rules.
- Allowed IPs per port are Terraform variables — never hardcoded in source code.
- Trivy scans the repository filesystem on every push; CRITICAL or HIGH vulnerabilities automatically block the deploy.
- Grafana runs with `user: "472"` (non-root user inside the container).
- All services are isolated in an internal Docker network (`monitor_net`); only Caddy exposes ports to the host.

---

*Built with ☁️ Linode · 🐳 Docker · 📊 Grafana · 🔥 Prometheus · 🔒 Wazuh · 🏗️ Terraform*
