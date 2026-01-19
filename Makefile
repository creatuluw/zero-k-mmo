###############################################################################
# Zero-K MMO Server - Makefile
# Simplifies local testing and Railway.app deployment
###############################################################################

.PHONY: help build run stop clean test deploy logs ssh status restart

# Default target
.DEFAULT_GOAL := help

# Configuration variables
PROJECT_NAME := zero-k-mmo
DOCKER_IMAGE := zero-k-server
CONTAINER_NAME := zero-k-server
GAME_PORT := 8200
LOBBY_PORT := 8452
DATA_DIR := ./data

# Colors for output
BLUE := \033[0;34m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
NC := \033[0m # No Color

###############################################################################
# Help target - displays all available commands
###############################################################################
help: ## Show this help message
	@echo "$(BLUE)Zero-K MMO Server - Makefile Commands$(NC)"
	@echo ""
	@echo "$(GREEN)Development & Testing:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(GREEN)Examples:$(NC)"
	@echo "  make build          # Build Docker image"
	@echo "  make run            # Start server locally"
	@echo "  make deploy         # Deploy to Railway"
	@echo "  make logs           # View Railway logs"

###############################################################################
# Build targets
###############################################################################
build: ## Build Docker image locally
	@echo "$(BLUE)Building Docker image...$(NC)"
	docker build -t $(DOCKER_IMAGE):latest .
	@echo "$(GREEN)✓ Build complete$(NC)"

build-no-cache: ## Build Docker image without cache
	@echo "$(BLUE)Building Docker image (no cache)...$(NC)"
	docker build --no-cache -t $(DOCKER_IMAGE):latest .
	@echo "$(GREEN)✓ Build complete$(NC)"

build-force: ## Force rebuild and restart
	@echo "$(YELLOW)Force rebuilding...$(NC)"
	$(MAKE) stop
	$(MAKE) build-no-cache
	$(MAKE) run

###############################################################################
# Run targets
###############################################################################
run: ## Run server locally in foreground
	@echo "$(BLUE)Starting Zero-K server locally...$(NC)"
	@echo "$(GREEN)Game Port: $(GAME_PORT)/UDP$(NC)"
	@echo "$(GREEN)Lobby Port: $(LOBBY_PORT)/TCP$(NC)"
	@echo ""
	@mkdir -p $(DATA_DIR)
	docker run -it --rm \
		--name $(CONTAINER_NAME) \
		-p $(GAME_PORT):8200/udp \
		-p $(LOBBY_PORT):8452/tcp \
		-v $(PWD)/data:/data/persistent \
		$(DOCKER_IMAGE):latest

run-detached: ## Run server in background
	@echo "$(BLUE)Starting Zero-K server in background...$(NC)"
	@mkdir -p $(DATA_DIR)
	docker run -d \
		--name $(CONTAINER_NAME) \
		-p $(GAME_PORT):8200/udp \
		-p $(LOBBY_PORT):8452/tcp \
		-v $(PWD)/data:/data/persistent \
		--restart unless-stopped \
		$(DOCKER_IMAGE):latest
	@echo "$(GREEN)✓ Server started in background$(NC)"
	@echo "Use 'make logs-local' to view logs"

run-dev: ## Run with development settings (verbose logging)
	@echo "$(BLUE)Starting Zero-K server in development mode...$(NC)"
	@mkdir -p $(DATA_DIR)
	docker run -it --rm \
		--name $(CONTAINER_NAME) \
		-p $(GAME_PORT):8200/udp \
		-p $(LOBBY_PORT):8452/tcp \
		-v $(PWD)/data:/data/persistent \
		-e LOG_LEVEL=debug \
		-e MAX_PLAYERS=4 \
		$(DOCKER_IMAGE):latest

###############################################################################
# Control targets
###############################################################################
stop: ## Stop running container
	@echo "$(BLUE)Stopping container...$(NC)"
	-docker stop $(CONTAINER_NAME) 2>/dev/null || true
	-docker rm $(CONTAINER_NAME) 2>/dev/null || true
	@echo "$(GREEN)✓ Container stopped$(NC)"

restart: stop run ## Restart the server

restart-detached: stop run-detached ## Restart server in background

###############################################################################
# Logs and monitoring
###############################################################################
logs-local: ## View local container logs
	docker logs -f $(CONTAINER_NAME)

logs-local-tail: ## Show last 50 lines of local logs
	docker logs --tail 50 $(CONTAINER_NAME)

logs-local-error: ## Show only error logs from local container
	docker logs $(CONTAINER_NAME) 2>&1 | grep -i error || true

stats: ## Show container resource usage
	@echo "$(BLUE)Container Statistics:$(NC)"
	docker stats $(CONTAINER_NAME) --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

inspect: ## Inspect container details
	docker inspect $(CONTAINER_NAME)

###############################################################################
# Testing targets
###############################################################################
test: ## Test if server is responding
	@echo "$(BLUE)Testing server connectivity...$(NC)"
	@echo "Testing UDP port $(GAME_PORT)..."
	@timeout 2 bash -c "cat < /dev/null > /dev/udp/127.0.0.1/$(GAME_PORT)" 2>/dev/null && echo "$(GREEN)✓ UDP port $(GAME_PORT) is open$(NC)" || echo "$(RED)✗ UDP port $(GAME_PORT) is not responding$(NC)"
	@echo "Testing TCP port $(LOBBY_PORT)..."
	@nc -zv 127.0.0.1 $(LOBBY_PORT) 2>/dev/null && echo "$(GREEN)✓ TCP port $(LOBBY_PORT) is open$(NC)" || echo "$(RED)✗ TCP port $(LOBBY_PORT) is not responding$(NC)"

test-full: ## Run comprehensive tests
	@echo "$(BLUE)Running comprehensive tests...$(NC)"
	@$(MAKE) build
	@$(MAKE) run-detached
	@echo "Waiting 10 seconds for server to start..."
	@sleep 10
	@$(MAKE) test
	@$(MAKE) logs-local-tail
	@$(MAKE) stats

###############################################################################
# Data management
###############################################################################
data-backup: ## Backup persistent data
	@echo "$(BLUE)Creating backup of persistent data...$(NC)"
	@mkdir -p backups
	tar -czf backups/backup_$(shell date +%Y%m%d_%H%M%S).tar.gz $(DATA_DIR)
	@echo "$(GREEN)✓ Backup created$(NC)"

data-restore: ## Restore from latest backup
	@echo "$(BLUE)Restoring from latest backup...$(NC)"
	@if [ -f backups/backup_*.tar.gz ]; then \
		tar -xzf $$(ls -t backups/backup_*.tar.gz | head -1); \
		echo "$(GREEN)✓ Restore complete$(NC)"; \
	else \
		echo "$(RED)✗ No backup found$(NC)"; \
	fi

data-clean: ## Clean old replay files
	@echo "$(BLUE)Cleaning old data files...$(NC)"
	@if [ -d "$(DATA_DIR)/replays" ]; then \
		find $(DATA_DIR)/replays -name "*.ssf" -mtime +30 -delete; \
		echo "$(GREEN)✓ Cleaned old replays$(NC)"; \
	fi
	@if [ -d "$(DATA_DIR)/logs" ]; then \
		find $(DATA_DIR)/logs -name "*.log" -mtime +7 -delete; \
		echo "$(GREEN)✓ Cleaned old logs$(NC)"; \
	fi

data-ls: ## List persistent data
	@echo "$(BLUE)Persistent Data Contents:$(NC)"
	@ls -lah $(DATA_DIR) 2>/dev/null || echo "$(YELLOW)No data directory found$(NC)"

data-shell: ## Open shell in data directory
	@echo "$(BLUE)Opening shell in data directory...$(NC)"
	docker exec -it $(CONTAINER_NAME) sh -c "cd /data/persistent && sh"

###############################################################################
# Railway deployment targets
###############################################################################
deploy: ## Deploy to Railway.app
	@echo "$(BLUE)Deploying to Railway.app...$(NC)"
	@if command -v railway >/dev/null 2>&1; then \
		railway up; \
		railway deploy; \
		echo "$(GREEN)✓ Deployment complete$(NC)"; \
	else \
		echo "$(RED)✗ Railway CLI not installed. Install with: npm install -g @railway/cli$(NC)"; \
	fi

deploy-build: ## Only build (don't deploy) on Railway
	@echo "$(BLUE)Building on Railway...$(NC)"
	railway up --force-build

deploy-logs: ## View Railway deployment logs
	@echo "$(BLUE)Fetching Railway logs...$(NC)"
	railway logs

deploy-status: ## Check Railway deployment status
	@echo "$(BLUE)Railway Status:$(NC)"
	railway status

deploy-url: ## Get Railway project URL
	@echo "$(BLUE)Railway URLs:$(NC)"
	railway domain

deploy-open: ## Open Railway project in browser
	railway open

deploy-env: ## Show Railway environment variables
	@echo "$(BLUE)Railway Environment Variables:$(NC)"
	railway variables list

deploy-env-set: ## Set Railway environment variable (usage: make deploy-env-set KEY=VALUE)
	@if [ -z "$(KEY)" ] || [ -z "$(VALUE)" ]; then \
		echo "$(RED)Usage: make deploy-env-set KEY=VALUE$(NC)"; \
	else \
		echo "Setting $(KEY)=$(VALUE)"; \
		railway variables set $(KEY)=$(VALUE); \
	fi

deploy-down: ## Remove Railway deployment
	@echo "$(YELLOW)This will remove the Railway deployment. Continue? (y/n)$(NC)"
	@read -r answer; \
	if [ "$$answer" = "y" ]; then \
		railway remove; \
		echo "$(GREEN)✓ Deployment removed$(NC)"; \
	fi

###############################################################################
# SSH and debugging
###############################################################################
ssh: ## SSH into Railway container
	railway open

ssh-local: ## SSH into local container
	docker exec -it $(CONTAINER_NAME) sh

debug: ## Run container with all ports exposed for debugging
	@echo "$(BLUE)Starting container in debug mode...$(NC)"
	docker run -it --rm \
		--name $(CONTAINER_NAME)-debug \
		-p 8200-8300:8200-8300/udp \
		-p 8452-8552:8452-8552/tcp \
		-v $(PWD)/data:/data/persistent \
		--cap-add=SYS_PTRACE \
		--security-opt seccomp=unconfined \
		$(DOCKER_IMAGE):latest \
		sh

###############################################################################
# Cleanup targets
###############################################################################
clean: stop ## Stop containers and clean up
	@echo "$(BLUE)Cleaning up...$(NC)"
	-docker rmi $(DOCKER_IMAGE):latest 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

clean-all: clean ## Clean everything including volumes
	@echo "$(YELLOW)Removing all Docker artifacts...$(NC)"
	-docker system prune -f
	-docker volume prune -f
	@echo "$(GREEN)✓ Deep cleanup complete$(NC)"

clean-data: ## Clean persistent data directory
	@echo "$(RED)This will delete all persistent data. Continue? (y/n)$(NC)"
	@read -r answer; \
	if [ "$$answer" = "y" ]; then \
		rm -rf $(DATA_DIR); \
		echo "$(GREEN)✓ Data directory cleaned$(NC)"; \
	fi

clean-logs: ## Clean log files
	@echo "$(BLUE)Cleaning log files...$(NC)"
	find $(DATA_DIR)/logs -name "*.log" -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Log files cleaned$(NC)"

###############################################################################
# Git and project management
###############################################################################
init: ## Initialize project structure
	@echo "$(BLUE)Initializing project...$(NC)"
	@mkdir -p $(DATA_DIR)/{replays,logs,config}
	@mkdir -p backups
	@mkdir -p maps
	@echo "$(GREEN)✓ Project structure initialized$(NC)"

status: ## Show overall project status
	@echo "$(BLUE)=== Zero-K MMO Server Status ===$(NC)"
	@echo ""
	@echo "$(GREEN)Docker Status:$(NC)"
	@docker ps -a --filter name=$(CONTAINER_NAME) --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "No containers found"
	@echo ""
	@echo "$(GREEN)Data Directory:$(NC)"
	@du -sh $(DATA_DIR) 2>/dev/null || echo "Not found"
	@echo ""
	@echo "$(GREEN)Railway Status:$(NC)"
	@-railway status 2>/dev/null || echo "Not deployed"

info: ## Show detailed project information
	@echo "$(BLUE)=== Zero-K MMO Server Information ===$(NC)"
	@echo ""
	@echo "$(GREEN)Configuration:$(NC)"
	@echo "  Project Name: $(PROJECT_NAME)"
	@echo "  Docker Image: $(DOCKER_IMAGE)"
	@echo "  Container: $(CONTAINER_NAME)"
	@echo "  Game Port: $(GAME_PORT)/UDP"
	@echo "  Lobby Port: $(LOBBY_PORT)/TCP"
	@echo "  Data Directory: $(PWD)/data"
	@echo ""
	@echo "$(GREEN)Quick Start:$(NC)"
	@echo "  1. make build          - Build Docker image"
	@echo "  2. make run            - Start server"
	@echo "  3. make deploy         - Deploy to Railway"
	@echo ""
	@echo "$(GREEN)Useful Commands:$(NC)"
	@echo "  make test             - Test connectivity"
	@echo "  make logs-local       - View logs"
	@echo "  make stop             - Stop server"
	@echo "  make clean            - Clean up"
	@echo ""

###############################################################################
# Quick start workflow
###############################################################################
quickstart: ## Quick start: build and run locally
	@echo "$(BLUE)Quick Start Workflow$(NC)"
	@echo "======================"
	@$(MAKE) init
	@$(MAKE) build
	@$(MAKE) run-detached
	@echo ""
	@echo "$(GREEN)✓ Server started!$(NC)"
	@echo "Use 'make logs-local' to monitor"
	@echo "Use 'make stop' to stop the server"

###############################################################################
# Production workflow
###############################################################################
production: ## Production deployment to Railway
	@echo "$(BLUE)Production Deployment$(NC)"
	@echo "======================="
	@$(MAKE) build-no-cache
	@$(MAKE) test
	@$(MAKE) deploy
	@echo ""
	@echo "$(GREEN)✓ Deployed to production!$(NC)"
	@$(MAKE) deploy-url
	@echo ""
	@echo "$(YELLOW)Next steps:$(NC)"
	@echo "1. Set up persistent volume in Railway dashboard"
	@echo "2. Configure environment variables"
	@echo "3. Test connectivity: make deploy-url"
	@echo "4. Monitor logs: make deploy-logs"

###############################################################################
# Development workflow
###############################################################################
dev: ## Development workflow with hot reload
	@echo "$(BLUE)Development Environment$(NC)"
	@echo "======================="
	@$(MAKE) build
	@$(MAKE) run-dev

###############################################################################
# Validation targets
###############################################################################
validate-docker: ## Validate Dockerfile syntax
	@echo "$(BLUE)Validating Dockerfile...$(NC)"
	docker build --dry-run -f Dockerfile .
	@echo "$(GREEN)✓ Dockerfile valid$(NC)"

validate-config: ## Validate game configuration
	@echo "$(BLUE)Validating configuration...$(NC)"
	@if [ -f gameconfig.txt ]; then \
		grep -q "\[SERVER\]" gameconfig.txt && echo "$(GREEN)✓ Configuration valid$(NC)" || echo "$(RED)✗ Invalid configuration$(NC)"; \
	else \
		echo "$(RED)✗ Configuration file not found$(NC)"; \
	fi

validate: validate-docker validate-config ## Run all validations

###############################################################################
# Documentation targets
###############################################################################
docs: ## Generate documentation
	@echo "$(BLUE)Generating documentation...$(NC)"
	@echo "# Zero-K MMO Server - Commands" > COMMANDS.md
	@echo "" >> COMMANDS.md
	@echo "Available Make targets:" >> COMMANDS.md
	@echo "" >> COMMANDS.md
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "- \`make %s\`: %s\n", $$1, $$2}' >> COMMANDS.md
	@echo "$(GREEN)✓ Documentation generated: COMMANDS.md$(NC)"

###############################################################################
# Update targets
###############################################################################
update-zero-k: ## Update Zero-K mod from GitHub
	@echo "$(BLUE)Updating Zero-K mod...$(NC)"
	@if [ -d "games/Zero-K/.git" ]; then \
		cd games/Zero-K && git pull origin master; \
	else \
		rm -rf games/Zero-K; \
		git clone --depth 1 https://github.com/ZeroK-RTS/Zero-K.git games/Zero-K; \
	fi
	@echo "$(GREEN)✓ Zero-K mod updated$(NC)"

update-spring: ## Update Spring engine (modify Dockerfile version)
	@echo "$(YELLOW)To update Spring engine:$(NC)"
	@echo "1. Edit Dockerfile"
	@echo "2. Update Spring download URL"
	@echo "3. Run: make build-no-cache"

###############################################################################
# Backup and restore targets (Railway)
###############################################################################
backup-railway: ## Backup Railway persistent data
	@echo "$(BLUE)Creating Railway backup...$(NC)"
	railway volumes list
	@echo "$(YELLOW)Note: Use Railway dashboard to download volume snapshot$(NC)"

###############################################################################
# Monitoring and alerts
###############################################################################
monitor: ## Start monitoring dashboard
	@echo "$(BLUE)Starting monitoring...$(NC)"
	watch -n 2 'docker stats $(CONTAINER_NAME) --no-stream 2>/dev/null || echo "Container not running"'

health-check: continuous health check
	@echo "$(BLUE)Running health check...$(NC)"
	@while true; do \
		clear; \
		date; \
		echo ""; \
		$(MAKE) test; \
		$(MAKE) stats; \
		sleep 5; \
	done

###############################################################################
# Utility targets
###############################################################################
ps: ## Show running containers
	docker ps -a --filter name=$(CONTAINER_NAME) --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}\t{{.Size}}"

version: ## Show version information
	@echo "$(BLUE)Zero-K MMO Server$(NC)"
	@echo "Version: 1.0.0"
	@echo "Spring RTS: 104.0.1"
	@echo "Zero-K: Latest from GitHub"

welcome: ## Display welcome message
	@echo "$(BLUE)"
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║          Zero-K MMO Server - Railway Deployment           ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo "$(NC)"
	@echo "$(GREEN)Quick Start:$(NC)"
	@echo "  make quickstart     - Build and run locally"
	@echo "  make production      - Deploy to Railway"
	@echo "  make help           - Show all commands"
	@echo ""
	@echo "$(GREEN)Documentation:$(NC)"
	@echo "  README.md           - Complete setup guide"
	@echo "  DEPLOYMENT.md       - Deployment documentation"
	@echo "  make docs           - Generate command reference"
	@echo ""
	@echo "$(YELLOW)Happy gaming! 🎮$(NC)"
