terraform {
  required_version = ">= 1.0"
  
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.4"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Red Docker para los contenedores
resource "docker_network" "app_network" {
  name = "app-network"
}

# Volumen para Prometheus
resource "docker_volume" "prometheus_data" {
  name = "prometheus-data"
}

# Volumen para Grafana
resource "docker_volume" "grafana_data" {
  name = "grafana-data"
}

# Contenedor de la aplicación
resource "docker_image" "app" {
  name = var.docker_image
  keep_locally = true
}

resource "docker_container" "app" {
  name  = "mi-app"
  image = docker_image.app.image_id

  ports {
    internal = 3000
    external = 3000
  }

  networks_advanced {
    name = docker_network.app_network.name
  }

  restart = "unless-stopped"

  healthcheck {
    test     = ["CMD", "node", "-e", "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"]
    interval = "30s"
    timeout  = "3s"
    retries  = 3
  }

  labels {
    label = "prometheus.scrape"
    value = "true"
  }

  labels {
    label = "prometheus.port"
    value = "3000"
  }
}

# Contenedor de Prometheus
resource "docker_image" "prometheus" {
  name = "prom/prometheus:latest"
}

resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = docker_image.prometheus.image_id

  ports {
    internal = 9090
    external = 9090
  }

  networks_advanced {
    name = docker_network.app_network.name
  }

  volumes {
    host_path      = abspath("${path.module}/../monitoring/prometheus.yml")
    container_path = "/etc/prometheus/prometheus.yml"
    read_only      = true
  }

  volumes {
    volume_name    = docker_volume.prometheus_data.name
    container_path = "/prometheus"
  }

  command = [
    "--config.file=/etc/prometheus/prometheus.yml",
    "--storage.tsdb.path=/prometheus",
    "--web.console.libraries=/etc/prometheus/console_libraries",
    "--web.console.templates=/etc/prometheus/consoles",
    "--storage.tsdb.retention.time=7d",
    "--web.enable-lifecycle"
  ]

  restart = "unless-stopped"
}

# Contenedor de Grafana
resource "docker_image" "grafana" {
  name = "grafana/grafana:latest"
}

resource "docker_container" "grafana" {
  name  = "grafana"
  image = docker_image.grafana.image_id

  ports {
    internal = 3001
    external = 3001
  }

  networks_advanced {
    name = docker_network.app_network.name
  }

  volumes {
    volume_name    = docker_volume.grafana_data.name
    container_path = "/var/lib/grafana"
  }

  volumes {
    host_path      = abspath("${path.module}/../monitoring/grafana-datasources.yml")
    container_path = "/etc/grafana/provisioning/datasources/datasources.yml"
    read_only      = true
  }

  env = [
    "GF_SECURITY_ADMIN_PASSWORD=admin",
    "GF_USERS_ALLOW_SIGN_UP=false",
    "GF_SERVER_HTTP_PORT=3001"
  ]

  restart = "unless-stopped"
}
