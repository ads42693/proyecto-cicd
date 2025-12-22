# 🚀 Proyecto CI/CD - DevSecOps Pipeline Completo

[![CI/CD Pipeline](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Infrastructure](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Container](https://img.shields.io/badge/Container-Docker-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Security](https://img.shields.io/badge/Security-Snyk-4C4A73?logo=snyk&logoColor=white)](https://snyk.io/)
[![Monitoring](https://img.shields.io/badge/Monitoring-Prometheus-E6522C?logo=prometheus&logoColor=white)](https://prometheus.io/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> Pipeline CI/CD local y reproducible con integración DevSecOps, IaC (Terraform), contenedores, pruebas automatizadas y observabilidad (Prometheus + Grafana). Pensado para ejecutarse con self-hosted runners en WSL2 o en una máquina Linux local.

---

## 📋 Tabla de Contenidos

- [Descripción](#-descripción)
- [Características](#-características-destacadas)
- [Arquitectura](#️-arquitectura)
- [Tecnologías](#-stack-tecnológico)
- [Inicio Rápido](#-inicio-rápido)
- [Pipeline CI/CD](#-pipeline-cicd)
- [Infraestructura](#️-infraestructura-terraform)
- [Monitoreo](#-monitoreo-y-observabilidad)
- [Seguridad](#-seguridad-devsecops)
- [API Reference](#-api-reference)
- [Desarrollo Local](#️-desarrollo-local)
- [Testing](#-testing)
- [Troubleshooting](#-troubleshooting)

---

## 📖 Descripción

Este proyecto implementa un **pipeline CI/CD completo** siguiendo las mejores prácticas de **DevSecOps**. Automatiza el ciclo completo desde el código fuente hasta el despliegue, incluyendo análisis de seguridad, testing, construcción de contenedores, gestión de infraestructura y monitoreo.

### Objetivos del Proyecto

- ✅ Demostrar implementación práctica de CI/CD en ambiente local
- ✅ Integrar herramientas de seguridad en el pipeline (DevSecOps)
- ✅ Automatizar infraestructura con Terraform (IaC)
- ✅ Implementar observabilidad con Prometheus y Grafana
- ✅ Aplicar mejores prácticas de contenedorización
- ✅ Gestionar estado de Terraform con GitHub Releases

---

## ✨ Características Destacadas

### 🔒 Seguridad (DevSecOps)
- **Análisis estático** con ESLint
- **Escaneo de vulnerabilidades** con Snyk
- **SBOM (Software Bill of Materials)** con CycloneDX
- **Imágenes Docker** optimizadas y seguras (multi-stage, usuario no privilegiado)

### 🧪 Quality Assurance
- **Testing automatizado** con Jest
- **Cobertura de código** con reportes detallados
- **Linting** con ESLint para consistencia de código
- **Verificación de imagen** antes del despliegue

### 🐳 Contenedorización
- **Dockerfile multi-stage** para optimización
- **Publicación automática** a GitHub Container Registry (GHCR)
- **Health checks** configurados
- **Limpieza automática** de imágenes antiguas

### 🏗️ Infrastructure as Code
- **Terraform** para gestión declarativa de infraestructura
- **Estado persistente** en GitHub Releases
- **Despliegue idempotente** de contenedores
- **Outputs estructurados** de URLs y recursos

### 📊 Observabilidad
- **Dashboard visual** con métricas en tiempo real
- **Prometheus** para recolección de métricas
- **Grafana** para visualización avanzada
- **Métricas personalizadas** de aplicación

### 🔄 CI/CD Avanzado
- **Self-hosted runner** en WSL2
- **Pipeline de 4 stages** (Security → Test → Build → Deploy)
- **Artifacts** persistentes entre jobs
- **Cleanup automático** de recursos
- **Workflow de destrucción** separado

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitHub Actions                           │
│  ┌──────────────┐  ┌──────────┐  ┌─────────┐  ┌─────────────┐   │
│  │   Security   │→ │   Test   │→ │  Build  │→ │   Deploy    │   │
│  │  (Snyk+ESL)  │  │  (Jest)  │  │ (Docker)│  │ (Terraform) │   │
│  └──────────────┘  └──────────┘  └─────────┘  └─────────────┘   │
│         ↓               ↓             ↓               ↓         │
│      SBOM          Coverage      GHCR Push      Infrastructure  │
└─────────────────────────────────────────────────────────────────┘
                                  ↓
                   ┌─────────────────────────────┐
                   │  GitHub Container Registry  │
                   │    (ghcr.io/owner/app)      │
                   └─────────────────────────────┘
                                  ↓
                        ┌────────────────────┐
                        │    Terraform       │
                        │  (Docker Provider) │
                        └────────────────────┘
                                  ↓
        ┌─────────────────────────┴───────────────────────┐
        ↓                         ↓                       ↓
┌──────────────────┐    ┌───────────────────┐    ┌─────────────────┐
│   Application    │    │    Prometheus     │    │     Grafana     │
│   (Node.js +     │◄───┤   (Metrics        │◄───┤   (Dashboard)   │
│   Express)       │    │   Collection)     │    │                 │
│   Port: 3000     │    │    Port: 9090     │    │    Port: 3001   │
└──────────────────┘    └───────────────────┘    └─────────────────┘
         │
         └─► Expone métricas en /metrics (Prometheus format)
```

### Flujo de Datos

1. **Push a GitHub** → Triggerea pipeline automático
2. **Security Scan** → ESLint + Snyk + SBOM
3. **Testing** → Jest con cobertura
4. **Build** → Docker multi-stage → Push a GHCR
5. **Deploy** → Terraform lee state desde GitHub Release → Despliega contenedores
6. **Monitoring** → Prometheus recolecta → Grafana visualiza

---

## 🛠 Stack Tecnológico

### CI/CD & DevOps
- **GitHub Actions** - Orquestación del pipeline
- **Self-hosted Runner** - Ejecución en WSL2 local
- **GitHub Container Registry** - Almacenamiento de imágenes
- **GitHub Releases** - Persistencia de Terraform state

### Infrastructure as Code
- **Terraform 1.13.4** - Gestión de infraestructura
- **Docker Provider** - Provisión de contenedores

### Runtime & Framework
- **Node.js 18+** - Runtime JavaScript
- **Express.js 4.18** - Framework web
- **prom-client** - Cliente de Prometheus para Node.js

### Security & Quality
- **Snyk** - Análisis de vulnerabilidades
- **ESLint** - Linter de JavaScript
- **CycloneDX** - Generación de SBOM
- **Jest** - Framework de testing
- **Supertest** - Testing de APIs HTTP

### Monitoring & Observability
- **Prometheus** - Sistema de métricas
- **Grafana** - Visualización de métricas
- **Custom Metrics** - Métricas de aplicación personalizadas

### Containerization
- **Docker** - Plataforma de contenedores
- **Multi-stage builds** - Optimización de imágenes
- **Alpine Linux** - Imagen base ligera

---

## 🚀 Inicio Rápido

### Prerequisitos

- **Docker Desktop** (con WSL2 integration en Windows)
- **Node.js 18+** y npm
- **Terraform 1.0+**
- **Git**
- **Cuenta de GitHub** con self-hosted runner configurado

### Instalación en 5 minutos

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/proyecto-cicd.git
cd proyecto-cicd

# 2. Instalar dependencias
npm install

# 3. Ejecutar tests localmente (opcional)
npm test

# 4. Construir imagen Docker
docker build -t proyecto-cicd-app:latest .

# 5. Desplegar con Terraform
cd terraform
terraform init
terraform apply -auto-approve

# 6. Acceder a los servicios
# Aplicación:  http://localhost:3000
# Prometheus:  http://localhost:9090
# Grafana:     http://localhost:3001 (admin/admin)
```

---

## 🔄 Pipeline CI/CD

### Arquitectura del Pipeline

El pipeline consta de **4 stages principales** ejecutados secuencialmente:

```yaml
Security Scan → Test → Build → Deploy
     ↓           ↓       ↓        ↓
  Artifacts  Artifacts GHCR   Terraform
```

### Stage 1: Security Analysis (3-4 min)

**Objetivo:** Detectar vulnerabilidades y problemas de código antes de la construcción.

```bash
├── ESLint Analysis
│   └── Análisis estático de código JavaScript
├── Snyk Security Scan
│   └── Escaneo de dependencias npm
└── SBOM Generation
    └── CycloneDX - Software Bill of Materials
```

**Outputs:**
- `sbom.json` - Lista completa de componentes y versiones
- `snyk-results.json` - Reporte de vulnerabilidades
- Artifacts subidos a GitHub Actions

**Métricas:**
- Vulnerabilidades encontradas
- Componentes totales
- Score de seguridad

### Stage 2: Testing (1-2 min)

**Objetivo:** Validar funcionalidad y generar métricas de cobertura.

```bash
├── Unit Tests (Jest)
│   ├── app.test.js - Tests de lógica
│   └── server.test.js - Tests de endpoints
└── Coverage Report
    └── Lcov format para visualización
```

**Outputs:**
- Reporte de cobertura HTML
- Métricas de tests pasados/fallados
- Artifact de cobertura

**Cobertura esperada:** >80% en branches, functions, lines

### Stage 3: Build & Publish (2-3 min)

**Objetivo:** Construir imagen Docker optimizada y publicarla en GHCR.

```bash
├── Docker Build (multi-stage)
│   ├── Builder stage - Compilación
│   └── Runtime stage - Ejecución
├── Image Verification
│   └── Inspección de capas y tamaño
├── Container Test
│   └── Health check endpoint
├── GHCR Push
│   ├── Tag con SHA del commit
│   └── Tag latest
└── Cleanup
    └── Eliminación de imágenes antiguas
```

**Imagen resultante:**
- **Base:** `node:18-alpine`
- **Usuario:** nodejs (no-root)
- **Tamaño:** ~150MB
- **Registry:** `ghcr.io/owner/proyecto-cicd-app`

### Stage 4: Deploy Infrastructure (3-4 min)

**Objetivo:** Desplegar infraestructura con Terraform y verificar servicios.

```bash
├── Download Terraform State
│   └── Desde GitHub Release
├── Terraform Workflow
│   ├── Init - Inicializar providers
│   ├── Validate - Validar sintaxis
│   ├── Plan - Planificar cambios
│   └── Apply - Aplicar cambios
├── Service Verification
│   ├── Health checks de contenedores
│   └── Endpoints de APIs
├── Integration Tests
│   └── Tests end-to-end básicos
└── Upload State
    └── Guardar en GitHub Release
```

**Recursos desplegados:**
- 3 Contenedores (app, prometheus, grafana)
- 1 Red Docker (app-network)
- 2 Volúmenes (prometheus-data, grafana-data)

### Stage Extra: Package Deliverables

Empaqueta automáticamente todos los entregables:
- Workflow YAML
- Archivos Terraform
- Dockerfile
- SBOM
- Estado de Terraform

---

## 🏗️ Infraestructura (Terraform)

### Recursos Gestionados

```hcl
# Docker Network
resource "docker_network" "app_network"

# Docker Volumes
resource "docker_volume" "prometheus_data"
resource "docker_volume" "grafana_data"

# Containers
resource "docker_container" "app"         # Aplicación Node.js
resource "docker_container" "prometheus"  # Métricas
resource "docker_container" "grafana"     # Dashboard
```

### Variables

```bash
docker_image = "ghcr.io/owner/proyecto-cicd-app:sha"  # Imagen desde GHCR
app_port = 3000                                        # Puerto aplicación
prometheus_port = 9090                                 # Puerto Prometheus
grafana_port = 3001                                    # Puerto Grafana
```

### Outputs

```bash
app_url         = "http://localhost:3000"
prometheus_url  = "http://localhost:9090"
grafana_url     = "http://localhost:3001"
container_ids   = { app: "...", prometheus: "...", grafana: "..." }
```

### Gestión de Estado

El estado de Terraform se almacena en **GitHub Releases**:

```bash
# Descarga automática en cada deploy
gh release download terraform-state --pattern "terraform.tfstate"

# Subida automática después del apply
gh release upload terraform-state terraform/terraform.tfstate --clobber
```

**Ventajas:**
- ✅ Persistencia entre ejecuciones del pipeline
- ✅ Versionado automático
- ✅ No requiere backend remoto (S3, etc.)
- ✅ Integrado nativamente con GitHub

### Comandos Terraform Útiles

```bash
# Inicializar
terraform init

# Planificar cambios
terraform plan -var="docker_image=ghcr.io/owner/app:latest"

# Aplicar
terraform apply -auto-approve

# Ver estado actual
terraform show

# Listar recursos
terraform state list

# Destruir infraestructura
terraform destroy -auto-approve
```

---

## 📊 Monitoreo y Observabilidad

### Dashboard Visual de la Aplicación

La aplicación incluye un **dashboard web moderno** con métricas en tiempo real:

![Dashboard Preview](docs/dashboard-preview.png)

**Características:**
- 📊 **Total de Requests** - Contador acumulado
- ⚡ **Requests/minuto** - Tráfico actual
- ⏱️ **Tiempo de Respuesta** - Latencia promedio
- 💚 **Estado del Sistema** - Health + Uptime
- 📈 **Gráfico de Barras** - Top endpoints más usados
- 🔗 **Links directos** a Prometheus y Grafana

**Actualización:** Automática cada 5 segundos

**URL:** http://localhost:3000

### Métricas Expuestas (Prometheus)

La aplicación expone métricas en formato Prometheus en `/metrics`:

```prometheus
# Métricas personalizadas
http_requests_total{method="GET",route="/api/data",status="200"} 145
http_request_duration_seconds{method="GET",route="/",status="200"} 0.023

# Métricas por defecto de Node.js
nodejs_heap_size_total_bytes 25165824
nodejs_heap_size_used_bytes 15728640
process_cpu_user_seconds_total 2.45
process_resident_memory_bytes 52428800
```

### Prometheus (http://localhost:9090)

**Configuración:**
```yaml
scrape_configs:
  - job_name: 'mi-aplicacion'
    scrape_interval: 10s
    static_configs:
      - targets: ['proyecto-cicd-app:3000']
```

**Queries útiles:**
```promql
# Rate de requests en 5 minutos
rate(http_requests_total[5m])

# Latencia promedio por endpoint
avg(http_request_duration_seconds) by (route)

# Uso de memoria
process_resident_memory_bytes / 1024 / 1024
```

### Grafana (http://localhost:3001)

**Credenciales por defecto:**
- Usuario: `admin`
- Contraseña: `admin`

**Datasource preconfigurado:**
- Prometheus en `http://prometheus:9090`

**Dashboards recomendados:**

1. **Overview Dashboard**
   - Total requests
   - Request rate
   - Error rate
   - Response time percentiles

2. **Performance Dashboard**
   - Latency heatmap
   - Request duration histogram
   - Top slow endpoints

3. **Resource Dashboard**
   - CPU usage
   - Memory usage
   - Heap statistics

---

## 🔒 Seguridad (DevSecOps)

### Análisis de Seguridad Integrado

#### 1. ESLint - Análisis Estático

**Configuración:** `.eslintrc.json`

```json
{
  "extends": "eslint:recommended",
  "rules": {
    "no-console": "off",
    "no-unused-vars": "error"
  }
}
```

**Ejecuta en cada push:** Detecta problemas de código antes de la construcción.

#### 2. Snyk - Vulnerabilidades

**Autenticación:** Via `SNYK_TOKEN` secret

**Threshold:** `--severity-threshold=high`

**Ejemplo de salida:**
```json
{
  "vulnerabilities": [
    {
      "id": "SNYK-JS-...",
      "title": "Prototype Pollution",
      "severity": "high",
      "package": "lodash@4.17.15"
    }
  ]
}
```

**Acción:** Pipeline continúa pero genera reporte para revisión.

#### 3. SBOM (Software Bill of Materials)

**Formato:** CycloneDX JSON

**Contenido:**
```json
{
  "bomFormat": "CycloneDX",
  "specVersion": "1.4",
  "components": [
    {
      "type": "library",
      "name": "express",
      "version": "4.18.2",
      "purl": "pkg:npm/express@4.18.2"
    }
  ]
}
```

**Uso:** Auditoría de componentes, compliance, trazabilidad.

### Seguridad en Docker

#### Multi-stage Build

```dockerfile
# Stage 1: Builder
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Stage 2: Runtime
FROM node:18-alpine
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001
USER nodejs  # ← No-root user
```

**Ventajas:**
- ✅ Imagen final más pequeña
- ✅ Sin herramientas de build en producción
- ✅ Usuario no privilegiado

#### Health Checks

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s \
  CMD node -e "require('http').get('http://localhost:3000/health', ...)"
```

#### Escaneo de Imagen

El pipeline incluye verificación pre-deploy:
```bash
docker inspect proyecto-cicd-app:latest
docker run --rm -d -p 3333:3000 proyecto-cicd-app:latest
curl -f http://localhost:3333/health || exit 1
```

---

## 📡 API Reference

### Endpoints Disponibles

#### `GET /`
Página principal con dashboard visual.

**Response:**
```html
<!DOCTYPE html>
<html>
  <!-- Dashboard HTML -->
</html>
```

#### `GET /health`
Health check endpoint para monitoring.

**Response:**
```json
{
  "status": "healthy",
  "uptime": 3600.5,
  "timestamp": "2024-01-15T10:30:00.000Z",
  "memory": {
    "rss": 52428800,
    "heapTotal": 25165824,
    "heapUsed": 15728640
  },
  "environment": "production"
}
```

**Status Codes:**
- `200 OK` - Servicio saludable
- `500 Internal Server Error` - Servicio degradado

#### `GET /metrics`
Métricas en formato Prometheus.

**Response:**
```prometheus
# HELP http_requests_total Total de solicitudes HTTP
# TYPE http_requests_total counter
http_requests_total{method="GET",route="/",status="200"} 145

# HELP http_request_duration_seconds Duración de las solicitudes HTTP
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{le="0.005",method="GET",route="/"} 100
```

**Content-Type:** `text/plain; version=0.0.4`

#### `GET /api/data`
Endpoint de ejemplo con datos de servicios.

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "nombre": "Servicio A",
      "status": "activo",
      "latencia": "45ms"
    }
  ],
  "timestamp": "2024-01-15T10:30:00.000Z",
  "requestCount": 1523
}
```

#### `GET /api/stats`
Estadísticas en tiempo real para el dashboard.

**Response:**
```json
{
  "totalRequests": 1523,
  "requestsPerMin": 25.4,
  "avgResponseTime": 42.5,
  "uptime": 3600.5,
  "endpointStats": [
    { "name": "/api/data", "count": 645 },
    { "name": "/health", "count": 420 },
    { "name": "/", "count": 358 }
  ],
  "timestamp": "2024-01-15T10:30:00.000Z"
}
```

**Actualización:** Llamado cada 5 segundos por el dashboard.

#### `POST /api/echo`
Echo endpoint para testing.

**Request:**
```json
{
  "message": "Hello World"
}
```

**Response:**
```json
{
  "received": {
    "message": "Hello World"
  },
  "timestamp": "2024-01-15T10:30:00.000Z",
  "headers": { ... }
}
```

---

## 🛠️ Desarrollo Local

### Setup del Entorno

```bash
# 1. Instalar dependencias
npm install

# 2. Ejecutar en modo desarrollo (con hot-reload)
npm run dev

# 3. En otra terminal, ver logs
tail -f logs/app.log
```

### Scripts Disponibles

```bash
npm start               # Iniciar servidor en producción
npm run dev             # Modo desarrollo con nodemon
npm test                # Ejecutar tests con Jest
npm run test:coverage   # Tests con cobertura
npm run lint            # Ejecutar ESLint
npm run lint:fix        # Auto-fix de problemas
```

### Variables de Entorno

```bash
# .env (crear en local, no commitear)
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug
```

### Estructura de Archivos

```
src/
├── app.js           # Lógica de aplicación
├── server.js        # Configuración del servidor Express
├── app.test.js      # Tests de app.js
└── server.test.js   # Tests de server.js

public/
└── index.html       # Dashboard frontend

monitoring/
├── prometheus.yml           # Config de Prometheus
└── grafana-datasources.yml  # Datasources de Grafana

terraform/
├── main.tf          # Recursos de infraestructura
├── variables.tf     # Variables de entrada
└── outputs.tf       # Outputs de recursos
```

---

## 🧪 Testing

### Framework: Jest

**Configuración:** `jest.config.js`

```javascript
module.exports = {
  testEnvironment: 'node',
  coverageThreshold: {
    global: {
      branches: 50,
      functions: 50,
      lines: 50,
      statements: 50
    }
  }
};
```

### Tests Unitarios

#### app.test.js
```javascript
describe('Application Logic', () => {
  test('should process data correctly', () => {
    const result = processData(input);
    expect(result).toBeDefined();
  });
});
```

#### server.test.js
```javascript
describe('API Endpoints', () => {
  test('GET /health returns 200', async () => {
    const response = await request(app).get('/health');
    expect(response.status).toBe(200);
    expect(response.body.status).toBe('healthy');
  });
});
```

### Ejecutar Tests

```bash
# Todos los tests
npm test

# Con watch mode
npm test -- --watch

# Test específico
npm test -- app.test.js

# Con cobertura detallada
npm run test:coverage

# Ver reporte HTML
open coverage/lcov-report/index.html
```

### Cobertura Esperada

```
--------------------|---------|----------|---------|---------|
File                | % Stmts | % Branch | % Funcs | % Lines |
--------------------|---------|----------|---------|---------|
All files           |   85.71 |    75.00 |   83.33 |   85.00 |
 app.js             |   90.00 |    80.00 |   85.71 |   89.47 |
 server.js          |   82.35 |    70.00 |   81.25 |   81.58 |
--------------------|---------|----------|---------|---------|
```

---

## 🐛 Troubleshooting

### Problema: Pipeline falla en Security Scan

**Síntomas:**
```
Error: Snyk not authenticated
```

**Solución:**
```bash
# 1. Crear token en https://app.snyk.io/account
# 2. Agregarlo como secret en GitHub: Settings → Secrets → SNYK_TOKEN
# 3. Re-ejecutar pipeline
```

### Problema: Docker daemon no responde

**Síntomas:**
```
Cannot connect to Docker daemon
```

**Solución:**
```bash
# Verificar Docker Desktop está corriendo
docker ps

# En WSL, verificar socket
ls -la /var/run/docker.sock

# Reiniciar Docker Desktop si es necesario
```

### Problema: Puerto ya en uso

**Síntomas:**
```
Error: Port 3000 is already in use
```

**Solución:**
```bash
# Ver qué proceso usa el puerto
sudo lsof -i :3000

# Matar proceso
sudo kill -9 <PID>

# O cambiar puerto en terraform/variables.tf
```

### Problema: Terraform state corrupto

**Síntomas:**
```
Error: state snapshot was created by Terraform v1.x.x
```

**Solución:**
```bash
# Eliminar state corrupto
rm terraform/terraform.tfstate

# Eliminar release en GitHub
gh release delete terraform-state --yes

# Re-ejecutar deploy (creará nuevo state)
terraform apply
```

### Problema: Tests fallan localmente

**Síntomas:**
```
FAIL src/server.test.js
```

**Solución:**
```bash
# Limpiar caché de Jest
npm test -- --clearCache

# Reinstalar dependencias
rm -rf node_modules package-lock.json
npm install

# Verificar versión de Node
node --version  # Debe ser >=18
```

### Problema: Contenedores no inician

**Síntomas:**
```
Error: Container exited with code 1
```

**Solución:**
```bash
# Ver logs del contenedor
docker logs proyecto-cicd-app

# Verificar health check
docker inspect proyecto-cicd-app | grep Health

# Reiniciar contenedores
make down && make up
```

### Problema: Métricas no aparecen en Prometheus

**Síntomas:**
- Prometheus no muestra targets
- Dashboard vacío

**Solución:**
```bash
# 1. Verificar que la app expone /metrics
curl http://localhost:3000/metrics

# 2. Verificar configuración de Prometheus
cat monitoring/prometheus.yml

# 3. Verificar que Prometheus puede alcanzar la app
docker exec prometheus ping proyecto-cicd-app

# 4. Revisar targets en Prometheus UI
# http://localhost:9090/targets
```

---

**Nota**: Este proyecto es con fines educativos para demostrar un pipeline CI/CD completo.
