#!/bin/bash

# Script para verificar cumplimiento de la rúbrica
# Uso: ./verificar-rubrica.sh

echo "======================================"
echo "Verificación de Rúbrica - Proyecto CI/CD"
echo "======================================"
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

TOTAL_SCORE=0
MAX_SCORE=100

print_check() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $2"
        TOTAL_SCORE=$((TOTAL_SCORE + $3))
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

print_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 1. PIPELINE CI/CD - 25%
print_section "1. Pipeline CI/CD (25%)"

# Verificar archivo workflow
if [ -f ".github/workflows/ci-cd.yml" ]; then
    print_check 0 "Workflow de GitHub Actions existe" 5
else
    print_check 1 "Workflow de GitHub Actions existe" 0
fi

# Verificar que use self-hosted runner
if grep -q "runs-on: self-hosted" .github/workflows/ci-cd.yml 2>/dev/null; then
    print_check 0 "Workflow configurado para self-hosted runner" 5
else
    print_check 1 "Workflow configurado para self-hosted runner" 0
fi

# Verificar stages del pipeline
STAGES=("security-scan" "test" "build" "deploy")
for stage in "${STAGES[@]}"; do
    if grep -q "$stage:" .github/workflows/ci-cd.yml 2>/dev/null; then
        print_check 0 "Stage '$stage' presente en workflow" 2
    else
        print_check 1 "Stage '$stage' presente en workflow" 0
    fi
done

# Verificar runner instalado
if [ -d "$HOME/actions-runner" ]; then
    print_check 0 "GitHub Actions runner instalado" 3
else
    print_check 1 "GitHub Actions runner instalado" 0
fi

# 2. INFRAESTRUCTURA - 20%
print_section "2. Infraestructura con Terraform (20%)"

# Verificar archivos Terraform
TF_FILES=("terraform/main.tf" "terraform/variables.tf" "terraform/outputs.tf")
for file in "${TF_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_check 0 "Archivo $file existe" 5
    else
        print_check 1 "Archivo $file existe" 0
    fi
done

# Verificar que Terraform esté inicializado
if [ -d "terraform/.terraform" ]; then
    print_check 0 "Terraform inicializado (terraform init ejecutado)" 5
else
    print_check 1 "Terraform inicializado" 0
fi

# 3. CONTENEDOR - 15%
print_section "3. Contenedor Docker (15%)"

# Verificar Dockerfile
if [ -f "Dockerfile" ]; then
    print_check 0 "Dockerfile existe" 5
else
    print_check 1 "Dockerfile existe" 0
fi

# Verificar multi-stage build
if grep -q "FROM.*AS builder" Dockerfile 2>/dev/null; then
    print_check 0 "Dockerfile usa multi-stage build" 3
else
    print_check 1 "Dockerfile usa multi-stage build" 0
fi

# Verificar usuario no privilegiado
if grep -q "USER nodejs" Dockerfile 2>/dev/null; then
    print_check 0 "Dockerfile usa usuario no privilegiado" 3
else
    print_check 1 "Dockerfile usa usuario no privilegiado" 0
fi

# Verificar imagen construida
if docker images | grep -q "mi-app"; then
    print_check 0 "Imagen Docker construida" 4
else
    print_check 1 "Imagen Docker construida" 0
fi

# 4. SEGURIDAD - 20%
print_section "4. Seguridad (20%)"

# Verificar SBOM
if [ -f "sbom.json" ]; then
    print_check 0 "SBOM generado (sbom.json)" 8
else
    print_check 1 "SBOM generado" 0
fi

# Verificar ESLint
if [ -f ".eslintrc.json" ]; then
    print_check 0 "ESLint configurado" 4
else
    print_check 1 "ESLint configurado" 0
fi

# Verificar configuración de análisis en workflow
if grep -q "eslint\|snyk\|cyclonedx" .github/workflows/ci-cd.yml 2>/dev/null; then
    print_check 0 "Análisis de seguridad en pipeline" 8
else
    print_check 1 "Análisis de seguridad en pipeline" 0
fi

# 5. OBSERVABILIDAD - 10%
print_section "5. Observabilidad (10%)"

# Verificar configuración Prometheus
if [ -f "monitoring/prometheus.yml" ]; then
    print_check 0 "Prometheus configurado" 3
else
    print_check 1 "Prometheus configurado" 0
fi

# Verificar configuración Grafana
if [ -f "monitoring/grafana-datasources.yml" ]; then
    print_check 0 "Grafana configurado" 3
else
    print_check 1 "Grafana configurado" 0
fi

# Verificar contenedores de monitoreo corriendo
if docker ps | grep -q "prometheus"; then
    print_check 0 "Prometheus corriendo" 2
else
    print_check 1 "Prometheus corriendo" 0
fi

if docker ps | grep -q "grafana"; then
    print_check 0 "Grafana corriendo" 2
else
    print_check 1 "Grafana corriendo" 0
fi

# 6. DOCUMENTACIÓN - 10%
print_section "6. Documentación (10%)"

# Verificar README
if [ -f "README.md" ] && [ $(wc -l < README.md) -gt 50 ]; then
    print_check 0 "README completo (>50 líneas)" 5
else
    print_check 1 "README completo" 0
fi

# Verificar capturas/evidencias
if [ -f "dashboard-screenshot.png" ] || [ -d "docs/evidencias" ]; then
    print_check 0 "Capturas de pantalla presentes" 5
else
    print_check 1 "Capturas de pantalla presentes" 0
fi

# RESUMEN FINAL
print_section "RESUMEN FINAL"

PERCENTAGE=$((TOTAL_SCORE * 100 / MAX_SCORE))

echo ""
echo "Puntuación obtenida: $TOTAL_SCORE / $MAX_SCORE puntos"
echo "Porcentaje: $PERCENTAGE%"
echo ""

if [ $PERCENTAGE -ge 90 ]; then
    echo -e "${GREEN}🎉 ¡EXCELENTE! Proyecto completo y listo para entregar${NC}"
elif [ $PERCENTAGE -ge 75 ]; then
    echo -e "${YELLOW}⚠️  BIEN. Revisa los items faltantes para mejorar${NC}"
else
    echo -e "${RED}❌ NECESITA TRABAJO. Completa los items faltantes${NC}"
fi

echo ""
echo "Recomendaciones:"
echo ""

# Recomendaciones específicas
if ! docker ps | grep -q "mi-app\|prometheus\|grafana"; then
    echo "• Ejecuta 'make up' para levantar los servicios"
fi

if [ ! -f "sbom.json" ]; then
    echo "• Genera el SBOM con: npm install -g @cyclonedx/cyclonedx-npm && cyclonedx-npm --output-file sbom.json"
fi

if [ ! -f "dashboard-screenshot.png" ] && [ ! -d "docs/evidencias" ]; then
    echo "• Toma capturas de pantalla del dashboard de Grafana"
    echo "• Crea carpeta: mkdir -p docs/evidencias"
fi

if [ ! -d "$HOME/actions-runner" ]; then
    echo "• Configura el GitHub Actions runner con: ./setup-github-runner.sh"
fi

if [ ! -d "terraform/.terraform" ]; then
    echo "• Inicializa Terraform con: cd terraform && terraform init"
fi

echo ""
echo "Para generar el archivo entregable:"
echo "  ./generar-entregables.sh TuEquipo"
echo ""
echo "======================================"
