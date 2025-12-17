#!/bin/bash

# Script para configurar GitHub Actions Self-hosted Runner en WSL
# Uso: ./setup-github-runner.sh

echo "======================================"
echo "GitHub Actions Self-hosted Runner Setup"
echo "======================================"
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar si estamos en WSL
if ! grep -q Microsoft /proc/version; then
    echo -e "${RED}✗ Este script debe ejecutarse en WSL${NC}"
    exit 1
fi

echo -e "${GREEN}✓ WSL detectado${NC}"

# Crear directorio para el runner
RUNNER_DIR="$HOME/actions-runner"
mkdir -p "$RUNNER_DIR"
cd "$RUNNER_DIR"

echo ""
echo "======================================"
echo "Instrucciones para configurar el runner:"
echo "======================================"
echo ""
echo "1. Ve a tu repositorio en GitHub"
echo "2. Settings → Actions → Runners"
echo "3. Click en 'New self-hosted runner'"
echo "4. Selecciona: Linux + x64"
echo "5. Copia los comandos de 'Download' y 'Configure'"
echo ""
echo -e "${YELLOW}IMPORTANTE: NO ejecutes './run.sh' todavía${NC}"
echo ""
echo "Presiona ENTER cuando hayas copiado los comandos..."
read

echo ""
echo "Ahora pega aquí el comando de DESCARGA (el que empieza con 'curl'):"
echo -e "${YELLOW}Ejemplo: curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://...${NC}"
read -r DOWNLOAD_CMD

echo ""
echo "Descargando runner..."
eval "$DOWNLOAD_CMD"

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Error al descargar el runner${NC}"
    exit 1
fi

echo ""
echo "Extrayendo archivos..."
tar xzf ./actions-runner-linux-*.tar.gz

echo ""
echo "Ahora pega aquí el comando de CONFIGURACIÓN (el que empieza con './config.sh'):"
echo -e "${YELLOW}Ejemplo: ./config.sh --url https://github.com/tu-usuario/tu-repo --token ...${NC}"
read -r CONFIG_CMD

echo ""
echo "Configurando runner..."
eval "$CONFIG_CMD"

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Error al configurar el runner${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ Runner configurado exitosamente${NC}"
echo ""
echo "======================================"
echo "Instalando como servicio"
echo "======================================"

# Instalar como servicio
sudo ./svc.sh install

echo ""
echo -e "${GREEN}✓ Servicio instalado${NC}"
echo ""
echo "Comandos útiles:"
echo "  Iniciar:  sudo ./svc.sh start"
echo "  Detener:  sudo ./svc.sh stop"
echo "  Estado:   sudo ./svc.sh status"
echo ""
echo "¿Deseas iniciar el runner ahora? (y/n)"
read -r START_NOW

if [ "$START_NOW" = "y" ] || [ "$START_NOW" = "Y" ]; then
    sudo ./svc.sh start
    echo ""
    echo -e "${GREEN}✓ Runner iniciado${NC}"
    echo ""
    echo "Verifica en GitHub que el runner aparezca como 'Idle' (verde)"
fi

echo ""
echo "======================================"
echo "✓ Configuración completada"
echo "======================================"
echo ""
echo "Próximos pasos:"
echo "1. Verifica en GitHub: Settings → Actions → Runners"
echo "2. Deberías ver tu runner en estado 'Idle'"
echo "3. Haz un push para probar el workflow"
echo ""
