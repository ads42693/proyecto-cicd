.PHONY: help install test lint lint-fix build deploy up down clean logs logs-prometheus logs-grafana status sbom entregables dev check restart evidencias demo

# Variables
IMAGE ?= proyecto-cicd-app
TAG ?= latest

help: ## Mostrar esta ayuda
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

install: ## Instalar dependencias
	@echo "Instalando dependencias..."
	npm install
	@echo "✓ Dependencias instaladas"

test: ## Ejecutar tests
	@echo "Ejecutando tests..."
	npm test

lint: ## Ejecutar linter
	@echo "Ejecutando ESLint..."
	npm run lint

lint-fix: ## Corregir problemas de linting
	@echo "Corrigiendo problemas de linting..."
	npm run lint:fix

build: ## Construir imagen Docker (local)
	@echo "Construyendo imagen Docker..."
	docker build -t $(IMAGE):$(TAG) -t $(IMAGE):latest .
	@echo "✓ Imagen construida: $(IMAGE):$(TAG)"

deploy: ## Desplegar infraestructura con Terraform (usando state remoto en Release)
	@echo "Desplegando con Terraform..."
	@if gh release view terraform-state >/dev/null 2>&1; then \
		echo "✅ Descargando state remoto..."; \
		gh release download terraform-state --pattern "terraform.tfstate" --dir terraform/ || echo "⚠️ No se encontró state previo"; \
    fi
	cd terraform && terraform init -upgrade && terraform apply -auto-approve
	@echo "✓ Infraestructura desplegada"

up: build deploy ## Construir y desplegar todo
	@echo "✓ Aplicación lista!"
	@echo ""
	@echo "Servicios disponibles:"
	@echo "  - Aplicación: http://localhost:3000"
	@echo "  - Prometheus: http://localhost:9090"
	@echo "  - Grafana:    http://localhost:3001 (admin/admin)"

down: ## Destruir infraestructura (usando state remoto en Release)
	@echo "Destruyendo infraestructura..."
	cd terraform && terraform destroy -auto-approve
	@echo "✓ Infraestructura destruida"

clean: down ## Limpiar todo (infraestructura + archivos temporales)
	@echo "Limpiando archivos temporales..."
	rm -rf node_modules coverage sbom.json *.tar *.zip
	rm -rf terraform/.terraform terraform/terraform.tfstate*
	@echo "✓ Limpieza completada"

logs: ## Ver logs de la aplicación
	@echo "Logs de la aplicación:"
	docker logs $(IMAGE) --tail=50 -f || echo "⚠️ Contenedor $(IMAGE) no encontrado"

logs-prometheus: ## Ver logs de Prometheus
	docker logs prometheus --tail=50 -f

logs-grafana: ## Ver logs de Grafana
	docker logs grafana --tail=50 -f

status: ## Ver estado de los contenedores
	@echo "Estado de contenedores:"
	@docker ps -a --filter "name=$(IMAGE)" --filter "name=prometheus" --filter "name=grafana" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

sbom: ## Generar SBOM (CycloneDX)
	@echo "Generando SBOM..."
	@if ! command -v cyclonedx-npm &> /dev/null; then \
		echo "Instalando CycloneDX CLI..."; \
		npm install -g @cyclonedx/cyclonedx-npm; \
	fi
	cyclonedx-npm --output-file sbom.json
	@echo "✓ SBOM generado: sbom.json"

entregables: ## Generar archivo comprimido para entregar
	@echo "Generando entregables..."
	@mkdir -p deliverables
	@cp .github/workflows/*.yml deliverables/ || true
	@cp terraform/*.tf deliverables/
	@cp Dockerfile deliverables/
	@[ -f sbom.json ] && cp sbom.json deliverables/ || echo "⚠️ sbom.json no encontrado (ejecuta 'make sbom')"
	@[ -f $(IMAGE)-*.tar.gz ] && cp $(IMAGE)-*.tar.gz deliverables/ || echo "⚠️ imagen exportada .tar.gz no encontrada"
	@tar -czf deliverables.tar.gz deliverables
	@echo "✓ Entregables empaquetados: deliverables.tar.gz"

dev: ## Ejecutar en modo desarrollo
	npm run dev

check: ## Verificar que todo esté instalado correctamente
	@echo "Verificando instalaciones..."
	@command -v node >/dev/null 2>&1 || { echo "✗ Node.js no está instalado"; exit 1; }
	@echo "✓ Node.js: $$(node --version)"
	@command -v npm >/dev/null 2>&1 || { echo "✗ npm no está instalado"; exit 1; }
	@echo "✓ npm: $$(npm --version)"
	@command -v docker >/dev/null 2>&1 || { echo "✗ Docker no está instalado"; exit 1; }
	@echo "✓ Docker: $$(docker --version)"
	@command -v terraform >/dev/null 2>&1 || { echo "✗ Terraform no está instalado"; exit 1; }
	@echo "✓ Terraform: $$(terraform --version | head -n1)"
	@echo ""
	@echo "✓ Todos los requisitos están instalados"

restart: ## Reiniciar todos los servicios
	@echo "Reiniciando servicios..."
	docker restart $(IMAGE) prometheus grafana || true
	@echo "✓ Servicios reiniciados"

evidencias: ## Crear carpeta para evidencias
	@mkdir -p docs/evidencias
	@echo "✓ Carpeta docs/evidencias creada"

demo: up ## Demostración completa del proyecto
	@echo ""
	@echo "======================================"
	@echo "🚀 Demostración del Proyecto CI/CD"
	@echo "======================================"
	@echo ""
	@sleep 2
	@echo "1. Servicios desplegados:"
	@docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
	@echo ""
	@sleep 2
	@echo "2. Probando endpoints..."
	@curl -s http://localhost:3000/health | jq .
	@echo ""
	@sleep 2
	@echo "3. URLs de acceso:"
	@echo "   - Aplicación:  http://localhost:3000"
	@echo "   - Prometheus:  http://localhost:9090"
	@echo "   - Grafana:     http://localhost:3001 (admin/admin)"
	@echo ""
	@echo "======================================"
	@echo "✓ Demo completada"
	@echo "======================================"
