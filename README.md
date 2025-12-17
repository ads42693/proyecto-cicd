# Proyecto CI/CD con GitHub Actions + Terraform + Docker

## Descripción

Proyecto de CI/CD completo con pipeline automatizado que incluye:
- Análisis de seguridad con ESLint y Snyk
- Testing automatizado con Jest
- Construcción de imagen Docker
- Generación de SBOM con CycloneDX
- Despliegue de infraestructura con Terraform
- Monitoreo con Prometheus y Grafana

## Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                   GitHub Actions                         │
│  ┌──────────┐  ┌──────┐  ┌───────┐  ┌─────────┐       │
│  │ Security │→ │ Test │→ │ Build │→ │ Deploy  │       │
│  └──────────┘  └──────┘  └───────┘  └─────────┘       │
└─────────────────────────────────────────────────────────┘
                            ↓
                    ┌──────────────┐
                    │  Terraform   │
                    └──────────────┘
                            ↓
        ┌───────────────────┴───────────────────┐
        ↓                   ↓                   ↓
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Mi App    │    │  Prometheus  │    │   Grafana   │
│  (Node.js)  │    │  (Métricas)  │    │ (Dashboard) │
└─────────────┘    └──────────────┘    └─────────────┘
```

## Requisitos Previos

### Software Necesario

- **WSL2** (Windows Subsystem for Linux)
- **Docker Desktop** con WSL2 integration habilitado
- **Node.js 18+** y npm
- **Terraform 1.0+**
- **Git**

### Instalación en WSL2

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Instalar Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

## Estructura del Proyecto

```
proyecto-cicd/
├── .github/
│   └── workflows/
│       └── ci-cd.yml              # Pipeline CI/CD
├── src/
│   ├── server.js                  # Aplicación Node.js
│   └── server.test.js             # Tests unitarios
├── terraform/
│   ├── main.tf                    # Configuración principal
│   ├── variables.tf               # Variables
│   └── outputs.tf                 # Outputs
├── monitoring/
│   ├── prometheus.yml             # Configuración Prometheus
│   └── grafana-datasources.yml    # Datasources Grafana
├── Dockerfile                     # Imagen Docker
├── package.json                   # Dependencias Node.js
├── .eslintrc.json                 # Configuración ESLint
├── jest.config.js                 # Configuración Jest
├── .dockerignore                  # Archivos ignorados por Docker
└── .gitignore                     # Archivos ignorados por Git
```

## Instalación y Uso

### 1. Clonar el Proyecto

```bash
git clone <tu-repositorio>
cd proyecto-cicd
```

### 2. Instalar Dependencias

```bash
npm install
```

### 3. Ejecutar Tests Localmente

```bash
# Tests
npm test

# Tests con coverage
npm run test:coverage

# Linter
npm run lint
```

### 4. Construir la Imagen Docker

```bash
docker build -t mi-app:latest .
```

### 5. Generar SBOM

```bash
# Instalar CycloneDX CLI
npm install -g @cyclonedx/cyclonedx-npm

# Generar SBOM
cyclonedx-npm --output-file sbom.json
```

### 6. Desplegar con Terraform

```bash
cd terraform

# Inicializar Terraform
terraform init

# Ver el plan
terraform plan

# Aplicar cambios
terraform apply
```

### 7. Acceder a los Servicios

Una vez desplegado:

- **Aplicación**: http://localhost:3000
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3001
  - Usuario: `admin`
  - Contraseña: `admin`

## Endpoints de la Aplicación

- `GET /` - Mensaje de bienvenida
- `GET /health` - Health check
- `GET /metrics` - Métricas de Prometheus
- `GET /api/data` - Datos de ejemplo
- `POST /api/echo` - Echo del body recibido

## Pipeline CI/CD

El pipeline de GitHub Actions incluye 4 stages:

### 1. Security Scan
- Análisis estático con ESLint
- Escaneo de vulnerabilidades con Snyk
- Generación de SBOM

### 2. Test
- Tests unitarios con Jest
- Generación de reporte de cobertura

### 3. Build
- Construcción de imagen Docker
- Exportación del artefacto

### 4. Deploy
- Inicialización de Terraform
- Despliegue de infraestructura
- Despliegue de contenedores

## Monitoreo

### Métricas Disponibles

La aplicación expone las siguientes métricas:

- `http_requests_total` - Total de requests HTTP
- `http_request_duration_seconds` - Duración de requests
- Métricas por defecto de Node.js (CPU, memoria, etc.)

### Dashboard de Grafana

Para crear un dashboard básico en Grafana:

1. Acceder a http://localhost:3001
2. Login con `admin/admin`
3. Ir a Dashboards → New → New Dashboard
4. Agregar panel con query: `rate(http_requests_total[5m])`

## Seguridad

### Análisis Implementados

- **ESLint**: Análisis estático del código
- **Snyk**: Escaneo de vulnerabilidades en dependencias
- **Docker**: Imagen multi-stage con usuario no privilegiado
- **SBOM**: Bill of Materials para auditoría

### Mejores Prácticas

- Imagen Docker basada en Alpine (ligera)
- Usuario no root en contenedor
- Health checks configurados
- Variables de entorno para configuración
- Secrets no incluidos en el código

## Limpieza de Recursos

Para detener y eliminar todos los recursos:

```bash
# Desde el directorio terraform/
terraform destroy

# O manualmente
docker stop mi-app prometheus grafana
docker rm mi-app prometheus grafana
docker network rm app-network
docker volume rm prometheus-data grafana-data
```

## Troubleshooting

### Error: Docker daemon no responde

```bash
# Verificar que Docker Desktop esté corriendo
docker ps

# Si está corriendo en WSL, verificar socket
ls -la /var/run/docker.sock
```

### Error: Puerto en uso

```bash
# Ver qué proceso usa el puerto
sudo lsof -i :3000

# Cambiar el puerto en terraform/variables.tf
```

### Tests fallan

```bash
# Limpiar caché de Jest
npm test -- --clearCache

# Reinstalar dependencias
rm -rf node_modules package-lock.json
npm install
```

## Entregables del Proyecto

Para generar el archivo comprimido con todos los entregables:

```bash
# Desde el directorio raíz del proyecto
./generar-entregables.sh EquipoX
```

Esto generará un archivo `Proyecto1_EquipoX.zip` con:
- Workflow de GitHub Actions
- Archivos Terraform
- Dockerfile
- SBOM (sbom.json)
- Screenshot del dashboard (si existe)

## Contribuir

1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -am 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear un Pull Request

## Licencia

MIT

## Autor

Tu Nombre / Tu Equipo

---

**Nota**: Este proyecto es con fines educativos para demostrar un pipeline CI/CD completo.
