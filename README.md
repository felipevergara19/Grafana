# Grafana Monitoring Stack

[English version below](#english-version)

---

## 🇪🇸 Versión en Español

Este proyecto proporciona un entorno completo de monitoreo de servidores e infraestructura utilizando **Grafana**, **Prometheus**, **Node Exporter**, **Caddy** (como proxy inverso con HTTPS automático) y **Watchtower** (para actualizaciones automáticas de contenedores). Además, utiliza **Terraform** para administrar la seguridad (firewall) del servidor en **Linode**.

### 🚀 Características principales

* **Grafana:** Visualización de dashboards y alertas.
* **Prometheus:** Recolección y almacenamiento de métricas (Time Series Database).
* **Node Exporter:** Exposición de métricas a nivel de sistema operativo y hardware (CPU, RAM, Disco, etc.).
* **Caddy:** Proxy inverso que gestiona automáticamente los certificados SSL/TLS mediante Let's Encrypt para conexiones HTTPS seguras.
* **Watchtower:** Actualiza de forma automática las imágenes Docker del stack.
* **Terraform:** Configuración automatizada como código (IaC) para administrar las reglas del firewall en Linode.
* **DevSecOps / CI-CD:** Despliegues automatizados definidos en flujos de trabajo de GitHub Actions.

### 🛠 Requisitos previos

* [Docker](https://docs.docker.com/get-docker/) y [Docker Compose](https://docs.docker.com/compose/install/) instalados en tu servidor.
* [Terraform](https://developer.hashicorp.com/terraform/downloads) instalado en tu máquina local.
* Un token de API de Linode (si decides administrar el firewall de tu instancia).

### ⚙️ Instalación y Configuración

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/tu-usuario/tu-repositorio.git
   cd tu-repositorio
   ```

2. **Configuración de Variables de Entorno:**
   * Copia el archivo `.env.example` a `.env` y configura tus variables (dominios, contraseñas de Grafana, tokens de OAuth, etc.).
   ```bash
   cp .env.example .env
   ```

3. **Configuración de Infraestructura (Terraform):**
   * Dirígete a la carpeta `terraform/`.
   * Copia el ejemplo de variables para ocultar las IPs antes de aplicarlas:
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   ```
   * Modifica `terraform.tfvars` para agregar tu `linode_token`, `instance_id` y restringir o permitir las IPs (por ejemplo, definir tu IP pública para conexiones SSH de forma segura).
   * Inicia y aplica los cambios:
   ```bash
   terraform init
   terraform apply
   ```

4. **Levantar los servicios:**
   * Regresa a la raíz del proyecto y arranca los contenedores:
   ```bash
   cd ..
   docker-compose up -d
   ```

5. **Acceso:**
   * Ingresa a `https://<TU_DOMINIO>` (el que configuraste en `.env`). Caddy aprovisionará automáticamente el certificado SSL.

### 🔒 Consideraciones de Seguridad
* No subas nunca tus archivos `.env` o `*.tfvars` al control de versiones (ya se encuentran excluidos en el `.gitignore`).
* Utiliza el archivo `terraform.tfvars` para configurar las IPs a las que quieres dar acceso vía Firewall, en lugar de dejarlas abiertas al mundo de manera directa en el código fuente.

---

<br>

<a name="english-version"></a>
## 🇬🇧 English Version

This project provides a complete server and infrastructure monitoring stack using **Grafana**, **Prometheus**, **Node Exporter**, **Caddy** (as a reverse proxy with automatic HTTPS), and **Watchtower** (for automatic container updates). Additionally, it uses **Terraform** to manage server security (firewall rules) on **Linode**.

### 🚀 Key Features

* **Grafana:** Dashboard visualization and alerting.
* **Prometheus:** Metrics gathering and time-series database.
* **Node Exporter:** OS and hardware level metrics exporter (CPU, RAM, Disk, etc.).
* **Caddy:** Reverse proxy that automatically manages Let's Encrypt SSL/TLS certificates for secure HTTPS connections.
* **Watchtower:** Automatically updates Docker images within the stack.
* **Terraform:** Infrastructure as Code (IaC) configuration to manage Linode firewall rules.
* **DevSecOps / CI-CD:** Automated deployments defined in GitHub Actions workflows.

### 🛠 Prerequisites

* [Docker](https://docs.docker.com/get-docker/) and [Docker Compose](https://docs.docker.com/compose/install/) installed on your server.
* [Terraform](https://developer.hashicorp.com/terraform/downloads) installed on your local machine.
* A Linode API Token (if you decide to manage your instance firewall).

### ⚙️ Installation and Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/your-repository.git
   cd your-repository
   ```

2. **Environment Variables Configuration:**
   * Copy the `.env.example` file to `.env` and set your variables (domains, Grafana passwords, OAuth tokens, etc.).
   ```bash
   cp .env.example .env
   ```

3. **Infrastructure Setup (Terraform):**
   * Navigate to the `terraform/` folder.
   * Copy the variable template to hide your IPs before applying:
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   ```
   * Edit `terraform.tfvars` to include your `linode_token`, `instance_id`, and to restrict or allow IPs (e.g., set your public IP for secure SSH access).
   * Initialize and apply the changes:
   ```bash
   terraform init
   terraform apply
   ```

4. **Start the services:**
   * Go back to the project root and spin up the containers:
   ```bash
   cd ..
   docker-compose up -d
   ```

5. **Access:**
   * Go to `https://<YOUR_DOMAIN>` (the one you set up in `.env`). Caddy will automatically provision the SSL certificate.

### 🔒 Security Considerations
* Never commit your `.env` or `*.tfvars` files to version control (they are already excluded in `.gitignore`).
* Use the `terraform.tfvars` file to configure allowed firewall IPs instead of hardcoding open IPs directly in the source code.
