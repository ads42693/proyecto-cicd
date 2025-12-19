.PHONY: help install test lint build deploy up down clean logs sbom entregables

help: ## Mostrar esta ayuda
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

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

build: ## Construir imagen Docker
	@echo "Construyendo imagen Docker..."
	docker build -t proyecto-cicd-app:latest .
	@echo "✓ Imagen construida: proyecto-cicd-app:latest"

deploy: ## Desplegar infraestructura con Terraform
	@echo "Desplegando con Terraform..."
	cd terraform && terraform init && terraform apply -auto-approve
	@echo "✓ Infraestructura desplegada"

up: build deploy ## Construir y desplegar todo
	@echo "✓ Aplicación lista!"
	@echo ""
	@echo "Servicios disponibles:"
	@echo "  - Aplicación: http://localhost:3000"
	@echo "  - Prometheus: http://localhost:9090"
	@echo "  - Grafana:    http://localhost:3001 (admin/admin)"

down: ## Destruir infraestructura
	@echo "Destruyendo infraestructura..."
	cd terraform && terraform destroy -auto-approve
	@echo "✓ Infraestructura destruida"

clean: down ## Limpiar todo (infraestructura + archivos temporales)
	@echo "Limpiando archivos temporales..."
	rm -rf node_modules coverage sbom.json *.tar *.zip
	rm -rf terraform/.terraform terraform/terraform.tfstate*
	@echo "✓ Limpieza completada"

logs: ## Ver logs de los contenedores
	@echo "Logs de la aplicación:"
	docker logs proyecto-cicd-app --tail=50 -f

logs-prometheus: ## Ver logs de Prometheus
	docker logs prometheus --tail=50 -f

logs-grafana: ## Ver logs de Grafana
	docker logs grafana --tail=50 -f

status: ## Ver estado de los contenedores
	@echo "Estado de contenedores:"
	@docker ps -a --filter "name=proyecto-cicd-app" --filter "name=prometheus" --filter "name=grafana" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

sbom: ## Generar SBOM
	@echo "Generando SBOM..."
	@if ! command -v cyclonedx-npm &> /dev/null; then \
		echo "Instalando CycloneDX CLI..."; \
		npm install -g @cyclonedx/cyclonedx-npm; \
	fi
	cyclonedx-npm --output-file sbom.json
	@echo "✓ SBOM generado: sbom.json"

entregables: ## Generar archivo comprimido para entregar
	@echo "Generando entregables..."
	@read -p "Nombre del equipo: " equipo; \
	chmod +x generar-entregables.sh; \
	./generar-entregables.sh $$equipo

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
	docker restart proyecto-cicd-app prometheus grafana
	@echo "✓ Servicios reiniciados"

verificar: ## Verificar cumplimiento de rúbrica
	@chmod +x verificar-rubrica.sh
	@./verificar-rubrica.sh

setup-runner: ## Configurar GitHub Actions runner
	@chmod +x setup-github-runner.sh
	@./setup-github-runner.sh

runner-start: ## Iniciar GitHub Actions runner
	@echo "Iniciando GitHub Actions runner..."
	@cd ~/actions-runner && sudo ./svc.sh start
	@echo "✓ Runner iniciado"

runner-stop: ## Detener GitHub Actions runner
	@echo "Deteniendo GitHub Actions runner..."
	@cd ~/actions-runner && sudo ./svc.sh stop
	@echo "✓ Runner detenido"

runner-status: ## Ver estado del runner
	@cd ~/actions-runner && sudo ./svc.sh status

runner-logs: ## Ver logs del runner
	@tail -n 50 ~/actions-runner/_diag/*.log

evidencias: ## Crear carpeta para evidencias
	@mkdir -p docs/evidencias
	@echo "✓ Carpeta docs/evidencias creada"
	@echo "Guarda aquí tus capturas de pantalla"

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

fix-workflow: ## Arreglar workflow bloqueado
	@echo "Aplicando fix para Snyk timeout..."
	@echo ""
	@echo "Pasos:"
	@echo "1. Cancela el workflow actual en GitHub (si está corriendo)"
	@echo "2. El workflow se ha actualizado con:"
	@echo "   - Timeout de 3 minutos en security scan"
	@echo "   - npm audit como alternativa a Snyk"
	@echo "   - Snyk opcional (solo si tienes token)"
	@echo ""
	@read -p "¿Workflow cancelado en GitHub? (y/n) " ans; \
	if [ "$ans" = "y" ]; then \
		git add .github/workflows/ci-cd.yml; \
		git commit -m "fix: Add timeout to security scans and use npm audit"; \
		git push; \
		echo ""; \
		echo "✓ Fix aplicado. Revisa GitHub Actions."; \
	else \
		echo "Cancela primero el workflow en GitHub y ejecuta este comando de nuevo"; \
	fi

cancel-runner-jobs: ## Matar procesos bloqueados del runner
	@echo "Matando procesos de npm/snyk bloqueados..."
	@pkill -9 snyk 2>/dev/null || echo "No hay procesos snyk"
	@pkill -9 npm 2>/dev/null || echo "No hay procesos npm bloqueados"
	@cd ~/actions-runner && sudo ./svc.sh restart
	@echo "✓ Runner reiniciado"

setup-snyk: ## Configurar Snyk localmente
	@chmod +x setup-snyk-local.sh
	@./setup-snyk-local.sh

test-snyk: ## Probar Snyk localmente
	@echo "Probando Snyk..."
	@if command -v snyk &> /dev/null; then \
		snyk test --severity-threshold=high || echo "Scan completed"; \
	else \
		echo "❌ Snyk no instalado. Ejecuta: make setup-snyk"; \
	fi

verify-snyk: ## Verificar autenticación de Snyk
	@echo "Verificando Snyk..."
	@if command -v snyk &> /dev/null; then \
		if snyk config get api 2>/dev/null | grep -q "api:"; then \
			echo "✓ Snyk está autenticado"; \
			snyk config get api; \
		else \
			echo "❌ Snyk NO está autenticado"; \
			echo "Ejecuta: snyk auth"; \
		fi; \
	else \
		echo "❌ Snyk no está instalado"; \
		echo "Ejecuta: make setup-snyk"; \
	fi