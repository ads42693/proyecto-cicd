variable "docker_image" {
  description = "Nombre de la imagen Docker a desplegar"
  type        = string
  default     = "proyecto-cicd-app:latest"
}

variable "app_port" {
  description = "Puerto externo para la aplicación"
  type        = number
  default     = 3000
}

variable "prometheus_port" {
  description = "Puerto externo para Prometheus"
  type        = number
  default     = 9090
}

variable "grafana_port" {
  description = "Puerto externo para Grafana"
  type        = number
  default     = 3001
}
