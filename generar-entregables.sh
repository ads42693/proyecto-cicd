#!/bin/bash

# Script para generar el archivo comprimido con todos los entregables
# Uso: ./generar-entregables.sh NombreEquipo

EQUIPO=${1:-"EquipoX"}
FECHA=$(date +%Y%m%d_%H%M%S)
CARPETA_TEMP="Proyecto1_${EQUIPO}"
ARCHIVO_FINAL="Proyecto1_${EQUIPO}.zip"

echo "======================================"
echo "Generando entregables del Proyecto 1"
echo "Equipo: $EQUIPO"
echo "======================================"

# Crear carpeta temporal
mkdir -p "$CARPETA_TEMP"

# 1. Copiar workflow de GitHub Actions
echo "✓ Copiando workflow de GitHub Actions..."
mkdir -p "$CARPETA_TEMP/.github/workflows"
cp .github/workflows/ci-cd.yml "$CARPETA_TEMP/.github/workflows/"

# 2. Copiar archivos Terraform
echo "✓ Copiando archivos Terraform..."
mkdir -p "$CARPETA_TEMP/terraform"
cp terraform/*.tf "$CARPETA_TEMP/terraform/"

# 3. Copiar Dockerfile
echo "✓ Copiando Dockerfile..."
cp Dockerfile "$CARPETA_TEMP/"

# 4. Generar o copiar SBOM
echo "✓ Generando SBOM..."
if ! command -v cyclonedx-npm &> /dev/null; then
    echo "  Instalando CycloneDX CLI..."
    npm install -g @cyclonedx/cyclonedx-npm
fi
cyclonedx-npm --output-file "$CARPETA_TEMP/sbom.json"

# 5. Capturar screenshot del dashboard (si existe)
echo "✓ Buscando captura del dashboard..."
if [ -f "dashboard-screenshot.png" ]; then
    cp dashboard-screenshot.png "$CARPETA_TEMP/"
    echo "  Screenshot encontrado y copiado"
else
    echo "  ADVERTENCIA: No se encontró dashboard-screenshot.png"
    echo "  Por favor, toma una captura del dashboard de Grafana y nómbrala 'dashboard-screenshot.png'"
fi

# 6. Incluir archivos adicionales importantes
echo "✓ Copiando archivos adicionales..."
cp package.json "$CARPETA_TEMP/"
cp README.md "$CARPETA_TEMP/"
mkdir -p "$CARPETA_TEMP/src"
cp src/*.js "$CARPETA_TEMP/src/"
mkdir -p "$CARPETA_TEMP/monitoring"
cp monitoring/*.yml "$CARPETA_TEMP/monitoring/"
cp .dockerignore "$CARPETA_TEMP/" 2>/dev/null || true
cp .eslintrc.json "$CARPETA_TEMP/" 2>/dev/null || true
cp jest.config.js "$CARPETA_TEMP/" 2>/dev/null || true

# 7. Crear archivo INFO
cat > "$CARPETA_TEMP/INFO.txt" << EOF
PROYECTO 1 - CI/CD CON GITHUB ACTIONS + TERRAFORM + DOCKER
===========================================================

Equipo: $EQUIPO
Fecha de generación: $(date)

CONTENIDO DEL ARCHIVO
=====================

1. .github/workflows/ci-cd.yml
   - Pipeline completo de CI/CD con GitHub Actions
   - Incluye: security scan, tests, build y deploy

2. terraform/
   - main.tf: Configuración principal de infraestructura
   - variables.tf: Variables de Terraform
   - outputs.tf: Outputs de Terraform

3. Dockerfile
   - Imagen Docker multi-stage
   - Usuario no privilegiado
   - Health checks configurados

4. sbom.json
   - Software Bill of Materials en formato CycloneDX
   - Lista completa de dependencias y versiones

5. dashboard-screenshot.png (si disponible)
   - Captura del dashboard de Grafana con métricas básicas

6. Archivos adicionales:
   - package.json: Dependencias del proyecto
   - README.md: Documentación completa
   - src/: Código fuente de la aplicación
   - monitoring/: Configuración de Prometheus y Grafana

INSTRUCCIONES DE DESPLIEGUE
============================

1. Instalar dependencias:
   npm install

2. Construir imagen Docker:
   docker build -t proyecto-cicd-app:latest .

3. Desplegar con Terraform:
   cd terraform
   terraform init
   terraform apply

4. Acceder a servicios:
   - Aplicación: http://localhost:3000
   - Prometheus: http://localhost:9090
   - Grafana: http://localhost:3001 (admin/admin)

CONTROLES DE SEGURIDAD
======================

- ESLint: Análisis estático del código
- Snyk: Escaneo de vulnerabilidades en dependencias
- SBOM: Trazabilidad de componentes de software
- Docker: Imagen con usuario no privilegiado

MONITOREO
=========

- Prometheus: Recolección de métricas
- Grafana: Visualización de métricas
- Métricas expuestas: /metrics endpoint

Para más información, consultar README.md
EOF

# 8. Comprimir todo
echo "✓ Comprimiendo archivos..."
zip -r "$ARCHIVO_FINAL" "$CARPETA_TEMP" > /dev/null

# 9. Limpiar carpeta temporal
rm -rf "$CARPETA_TEMP"

echo ""
echo "======================================"
echo "✓ Archivo generado exitosamente:"
echo "  $ARCHIVO_FINAL"
echo ""
echo "Tamaño: $(du -h "$ARCHIVO_FINAL" | cut -f1)"
echo "======================================"
echo ""
echo "IMPORTANTE: Antes de entregar, asegúrate de:"
echo "1. Incluir screenshot del dashboard de Grafana"
echo "2. Verificar que todos los archivos estén presentes"
echo "3. Probar que el despliegue funcione correctamente"
echo ""
