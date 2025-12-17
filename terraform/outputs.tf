output "app_url" {
  description = "URL de la aplicación"
  value       = "http://localhost:${docker_container.app.ports[0].external}"
}

output "prometheus_url" {
  description = "URL de Prometheus"
  value       = "http://localhost:${docker_container.prometheus.ports[0].external}"
}

output "grafana_url" {
  description = "URL de Grafana"
  value       = "http://localhost:${docker_container.grafana.ports[0].external}"
}

output "container_ids" {
  description = "IDs de los contenedores creados"
  value = {
    app        = docker_container.app.id
    prometheus = docker_container.prometheus.id
    grafana    = docker_container.grafana.id
  }
}
