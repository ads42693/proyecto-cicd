#!/bin/bash

# Script para configurar Snyk en el runner local
# Uso: ./setup-snyk-local.sh

echo "======================================"
echo "Configuración de Snyk para Runner Local"
echo "======================================"
echo ""

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verificar si Snyk está instalado
if ! command -v snyk &> /dev/null; then
    echo "Instalando Snyk CLI..."
    npm install -g snyk
    echo -e "${GREEN}✓ Snyk instalado${NC}"
else
    echo -e "${GREEN}✓ Snyk ya está instalado${NC}"
fi

echo ""
echo "======================================"
echo "Autenticación de Snyk"
echo "======================================"
echo ""
echo "Opción 1: Autenticación con cuenta (RECOMENDADO)"
echo "  1. Crea una cuenta gratuita en https://snyk.io/signup"
echo "  2. Ejecuta el siguiente comando y sigue las instrucciones"
echo ""
echo -e "${YELLOW}snyk auth${NC}"
echo ""
echo "Esto abrirá tu navegador para autenticarte."
echo ""
echo "¿Deseas autenticarte ahora? (y/n)"
read -r AUTH_NOW

if [ "$AUTH_NOW" = "y" ] || [ "$AUTH_NOW" = "Y" ]; then
    echo ""
    echo "Autenticando con Snyk..."
    snyk auth
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ Autenticación exitosa${NC}"
        echo ""
        
        # Probar que funciona
        echo "Probando Snyk..."
        cd ~/proyecto-cicd
        snyk test --severity-threshold=high || echo "Scan completed"
        
        echo ""
        echo -e "${GREEN}✓ Snyk configurado correctamente${NC}"
        echo ""
        echo "El token se guardó en: ~/.config/configstore/snyk.json"
        echo "El runner local ahora podrá usar Snyk automáticamente"
    else
        echo ""
        echo "❌ Error en la autenticación"
        echo "Intenta manualmente: snyk auth"
    fi
else
    echo ""
    echo "Puedes autenticarte después ejecutando:"
    echo "  snyk auth"
fi

echo ""
echo "======================================"
echo "Opción 2: Usar Token Directamente"
echo "======================================"
echo ""
echo "Si prefieres usar un token:"
echo "1. Ve a https://app.snyk.io/account"
echo "2. Copia tu token"
echo "3. Ejecuta: snyk auth YOUR_TOKEN"
echo ""

echo "======================================"
echo "Verificación"
echo "======================================"
echo ""
echo "Para verificar que Snyk está configurado:"
echo "  snyk test"
echo ""
echo "Para ver tu configuración:"
echo "  cat ~/.config/configstore/snyk.json"
echo ""
