###############################################################################
# Evolution RTS Server - Makefile
# Simplifies local testing and Railway.app deployment
###############################################################################

.PHONY: help build run stop clean test deploy logs ssh status restart

# Default target
.DEFAULT_GOAL := help

# Configuration variables
PROJECT_NAME := evolution-rts
DOCKER_IMAGE := evolution-rts-server
CONTAINER_NAME := evolution-rts-server
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
	@echo "$(BLUE)Evolution RTS Server - Makefile Commands$(NC)"
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
	@echo "$(BLUE)Starting Evolution RTS server locally...$(NC)"
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
	@echo "$(BLUE)Starting Evolution RTS server in background...$(NC)"
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
	@echo "$(BLUE)Starting Evolution RTS server in development mode...$(NC)"
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
# Management targets
###############################################################################
stop: ## Stop running server
	@echo "$(YELLOW)Stopping server...$(NC)"
	docker stop $(CONTAINER_NAME) 2>/dev/null || true
	docker rm $(CONTAINER_NAME) 2>/dev/null || true
	@echo "$(GREEN)✓ Server stopped$(NC)"

restart: ## Restart server
	@echo "$(YELLOW)Restarting server...$(NC)"
	$(MAKE) stop
	$(MAKE) run-detached
	@echo "$(GREEN)✓ Server restarted$(NC)"

clean: ## Remove Docker images and containers
	@echo "$(YELLOW)Cleaning up...$(NC)"
	docker stop $(CONTAINER_NAME) 2>/dev/null || true
	docker rm $(CONTAINER_NAME) 2>/dev/null || true
	docker rmi $(DOCKER_IMAGE):latest 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

clean-all: ## Remove all Docker images, containers, and data
	@echo "$(RED)Cleaning everything...$(NC)"
	docker stop $(CONTAINER_NAME) 2>/dev/null || true
	docker rm $(CONTAINER_NAME) 2>/dev/null || true
	docker rmi $(DOCKER_IMAGE):latest 2>/dev/null || true
	rm -rf $(DATA_DIR)
	@echo "$(GREEN)✓ Complete cleanup finished$(NC)"

###############################################################################
# Testing targets
###############################################################################
test: build ## Test server connectivity
	@echo "$(BLUE)Testing server...$(NC)"
	@echo "$(YELLOW)Starting server in background...$(NC)"
	@$(MAKE) run-detached > /dev/null 2>&1
	@sleep 5
	@echo "$(YELLOW)Checking if server is running...$(NC)"
	@if docker ps | grep -q $(CONTAINER_NAME); then \
		echo "$(GREEN)✓ Server is running$(NC)"; \
		echo "$(GREEN)✓ Container healthy$(NC)"; \
	else \
		echo "$(RED)✗ Server is not running$(NC)"; \
		$(MAKE) stop; \
		exit 1; \
	fi
	@echo "$(YELLOW)Checking ports...$(NC)"
	@if command -v nc >/dev/null 2>&1; then \
		if nc -z localhost $(GAME_PORT) 2>/dev/null; then \
			echo "$(GREEN)✓ Port $(GAME_PORT)/UDP is accessible$(NC)"; \
		else \
			echo "$(YELLOW)⚠ Port $(GAME_PORT)/UDP might not be accessible (UDP check limited)$(NC)"; \
		fi; \
		if nc -z localhost $(LOBBY_PORT) 2>/dev/null; then \
			echo "$(GREEN)✓ Port $(LOBBY_PORT)/TCP is accessible$(NC)"; \
		else \
			echo "$(RED)✗ Port $(LOBBY_PORT)/TCP is not accessible$(NC)"; \
			$(MAKE) stop; \
			exit 1; \
		fi; \
	else \
		echo "$(YELLOW)⚠ netcat not installed, skipping port checks$(NC)"; \
	fi
	@echo "$(GREEN)✓ All tests passed$(NC)"
	@$(MAKE) stop

test-quick: ## Quick server check (no build)
	@echo "$(BLUE)Quick server check...$(NC)"
	@if docker ps | grep -q $(CONTAINER_NAME); then \
		echo "$(GREEN)✓ Server is running$(NC)"; \
		docker logs --tail 10 $(CONTAINER_NAME); \
	else \
		echo "$(RED)✗ Server is not running$(NC)"; \
		exit 1; \
	fi

###############################################################################
# Logging targets
###############################################################################
logs: ## View Railway logs (requires Railway CLI)
	@echo "$(BLUE)Viewing Railway logs...$(NC)"
	@command -v railway >/dev/null 2>&1 || { \
		echo "$(RED)Railway CLI not installed$(NC)"; \
		echo "$(YELLOW)Install with: npm install -g @railway/cli$(NC)"; \
		exit 1; \
	}
	railway logs

logs-local: ## View local server logs
	@echo "$(BLUE)Viewing local server logs...$(NC)"
	docker logs -f $(CONTAINER_NAME) 2>/dev/null || \
		echo "$(RED)Server is not running. Start with 'make run' or 'make run-detached'$(NC)"

logs-persistent: ## View persistent logs from disk
	@echo "$(BLUE)Viewing persistent logs...$(NC)"
	@if [ -f "$(DATA_DIR)/logs/server.log" ]; then \
		tail -f $(DATA_DIR)/logs/server.log; \
	else \
		echo "$(RED)No persistent logs found$(NC)"; \
	fi

###############################################################################
# Railway deployment targets
###############################################################################
init: ## Initialize Railway project
	@echo "$(BLUE)Initializing Railway project...$(NC)"
	@command -v railway >/dev/null 2>&1 || { \
		echo "$(RED)Railway CLI not installed$(NC)"; \
		echo "$(YELLOW)Install with: npm install -g @railway/cli$(NC)"; \
		exit 1; \
	}
	railway init
	@echo "$(GREEN)✓ Railway project initialized$(NC)"

deploy: ## Deploy to Railway
	@echo "$(BLUE)Deploying to Railway...$(NC)"
	@command -v railway >/dev/null 2>&1 || { \
		echo "$(RED)Railway CLI not installed$(NC)"; \
		echo "$(YELLOW)Install with: npm install -g @railway/cli$(NC)"; \
		exit 1; \
	}
	railway up
	railway deploy
	@echo "$(GREEN)✓ Deployment complete$(NC)"

deploy-force: ## Force redeploy to Railway
	@echo "$(BLUE)Force redeploying to Railway...$(NC)"
	@command -v railway >/dev/null 2>&1 || { \
		echo "$(RED)Railway CLI not installed$(NC)"; \
		echo "$(YELLOW)Install with: npm install -g @railway/cli$(NC)"; \
		exit 1; \
	}
	railway up
	railway deploy --force
	@echo "$(GREEN)✓ Force deployment complete$(NC)"

domain: ## Get Railway domain URL
	@echo "$(BLUE)Getting Railway domain...$(NC)"
	@command -v railway >/dev/null 2>&1 || { \
		echo "$(RED)Railway CLI not installed$(NC)"; \
		exit 1; \
	}
	railway domain

status: ## Check Railway deployment status
	@echo "$(BLUE)Checking Railway status...$(NC)"
	@command -v railway >/dev/null 2>&1 || { \
		echo "$(RED)Railway CLI not installed$(NC)"; \
		exit 1; \
	}
	railway status

###############################################################################
# Monitoring targets
###############################################################################
stats: ## View server resource usage
	@echo "$(BLUE)Server resource usage:$(NC)"
	@if docker ps | grep -q $(CONTAINER_NAME); then \
		docker stats --no-stream $(CONTAINER_NAME); \
	else \
		echo "$(RED)Server is not running$(NC)"; \
	fi

health: ## Check server health
	@echo "$(BLUE)Server health check:$(NC)"
	@if docker ps | grep -q $(CONTAINER_NAME); then \
		echo "$(GREEN)✓ Container is running$(NC)"; \
		docker inspect --format='{{.State.Health.Status}}' $(CONTAINER_NAME) 2>/dev/null || echo "$(YELLOW)Health check not configured$(NC)"; \
	else \
		echo "$(RED)✗ Container is not running$(NC)"; \
		exit 1; \
	fi

monitor: ## Monitor server in real-time
	@echo "$(BLUE)Monitoring server (press Ctrl+C to stop)...$(NC)"
	@watch -n 2 'docker stats --no-stream $(CONTAINER_NAME)'

###############################################################################
# SSH targets
###############################################################################
ssh: ## SSH into running container
	@echo "$(BLUE)Opening shell in container...$(NC)"
	@docker exec -it $(CONTAINER_NAME) bash || \
		echo "$(RED)Server is not running$(NC)"

ssh-railway: ## SSH into Railway container
	@echo "$(BLUE)Opening shell in Railway container...$(NC)"
	@command -v railway >/dev/null 2>&1 || { \
		echo "$(RED)Railway CLI not installed$(NC)"; \
		exit 1; \
	}
	railway shell

###############################################################################
# Configuration targets
###############################################################################
config: ## Show current configuration
	@echo "$(BLUE)Current Configuration:$(NC)"
	@echo ""
	@echo "Project Name: $(PROJECT_NAME)"
	@echo "Docker Image: $(DOCKER_IMAGE)"
	@echo "Container Name: $(CONTAINER_NAME)"
	@echo "Game Port: $(GAME_PORT)/UDP"
	@echo "Lobby Port: $(LOBBY_PORT)/TCP"
	@echo "Data Directory: $(DATA_DIR)"
	@echo ""
	@echo "$(GREEN)Docker Images:$(NC)"
	@docker images $(DOCKER_IMAGE) 2>/dev/null || echo "  No images built"
	@echo ""
	@echo "$(GREEN)Running Containers:$(NC)"
	@docker ps --filter "name=$(CONTAINER_NAME)" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "  No containers running"

config-env: ## Set environment variables for Docker
	@echo "$(BLUE)Current Environment Variables:$(NC)"
	@echo "SERVER_NAME=$(SERVER_NAME:-Persistent Evolution RTS Server)"
	@echo "MAX_PLAYERS=$(MAX_PLAYERS:-16)"
	@echo "PORT=$(PORT:-8200)"
	@echo "LOBBY_PORT=$(LOBBY_PORT:-8452)"
	@echo "GAME_MOD=$(GAME_MOD:-Evolution RTS)"

###############################################################################
# Backup targets
###############################################################################
backup: ## Create backup of persistent data
	@echo "$(BLUE)Creating backup...$(NC)"
	@if [ -d "$(DATA_DIR)" ]; then \
		tar -czf evolution-rts-backup-$$(date +%Y%m%d_%H%M%S).tar.gz $(DATA_DIR); \
		echo "$(GREEN)✓ Backup created$(NC)"; \
		ls -lh evolution-rts-backup-*.tar.gz | tail -1; \
	else \
		echo "$(YELLOW)No data to backup$(NC)"; \
	fi

restore: ## Restore from backup (specify FILE=filename.tar.gz)
	@echo "$(BLUE)Restoring from backup...$(NC)"
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Error: Specify backup file with FILE=filename.tar.gz$(NC)"; \
		exit 1; \
	fi
	@if [ ! -f "$(FILE)" ]; then \
		echo "$(RED)Error: Backup file not found: $(FILE)$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Stopping server...$(NC)"
	@$(MAKE) stop
	@echo "$(YELLOW)Extracting backup...$(NC)"
	@tar -xzf $(FILE)
	@echo "$(GREEN)✓ Backup restored$(NC)"
	@echo "$(YELLOW)Starting server...$(NC)"
	@$(MAKE) run-detached

###############################################################################
# Maintenance targets
###############################################################################
update: ## Pull latest Evolution RTS mod
	@echo "$(BLUE)Updating Evolution RTS mod...$(NC)"
	docker run --rm \
		-v $(PWD)/data:/data \
		$(DOCKER_IMAGE):latest \
		sh -c "cd /spring/games/Evolution\ RTS && git pull"
	@echo "$(GREEN)✓ Mod updated$(NC)"

update-engine: ## Update Spring engine (manual - edit Dockerfile)
	@echo "$(BLUE)To update Spring engine:$(NC)"
	@echo "1. Edit Dockerfile"
	@echo "2. Change the Spring version URL"
	@echo "3. Run: make build-no-cache"
	@echo "4. Run: make deploy-force"

cleanup-old: ## Cleanup old replay and log files
	@echo "$(BLUE)Cleaning up old files...$(NC)"
	@if [ -d "$(DATA_DIR)/replays" ]; then \
		find $(DATA_DIR)/replays -name "*.ssf" -mtime +30 -delete; \
		echo "$(GREEN)✓ Old replays removed$(NC)"; \
	fi
	@if [ -d "$(DATA_DIR)/logs" ]; then \
		find $(DATA_DIR)/logs -name "*.log" -mtime +7 -delete; \
		echo "$(GREEN)✓ Old logs removed$(NC)"; \
	fi

analyze: ## Analyze replay files
	@echo "$(BLUE)Analyzing replays...$(NC)"
	@if [ -d "$(DATA_DIR)/replays" ]; then \
		echo "Total replays: $$(find $(DATA_DIR)/replays -name '*.ssf' | wc -l)"; \
		echo "Total size: $$(du -sh $(DATA_DIR)/replays | cut -f1)"; \
		echo "Oldest: $$(ls -lt $(DATA_DIR)/replays/*.ssf | tail -1 | awk '{print $$6, $$7, $$8}')"; \
		echo "Newest: $$(ls -lt $(DATA_DIR)/replays/*.ssf | head -1 | awk '{print $$6, $$7, $$8}')"; \
	else \
		echo "$(YELLOW)No replays found$(NC)"; \
	fi

###############################################################################
# Utility targets
###############################################################################
install: ## Install required tools
	@echo "$(BLUE)Installing required tools...$(NC)"
	@if command -v apt-get >/dev/null 2>&1; then \
		echo "Detected Debian/Ubuntu"; \
		sudo apt-get update; \
		sudo apt-get install -y docker.io docker-compose netcat; \
	elif command -v brew >/dev/null 2>&1; then \
		echo "Detected macOS (Homebrew)"; \
		brew install docker docker-compose netcat; \
	else \
		echo "$(RED)Unknown package manager$(NC)"; \
		echo "$(YELLOW)Please install Docker and netcat manually$(NC)"; \
	fi
	@echo "$(GREEN)✓ Tools installed$(NC)"

install-railway: ## Install Railway CLI
	@echo "$(BLUE)Installing Railway CLI...$(NC)"
	npm install -g @railway/cli
	@echo "$(GREEN)✓ Railway CLI installed$(NC)"
	@echo "$(YELLOW)Run 'railway login' to authenticate$(NC)"

info: ## Display project information
	@echo "$(BLUE)Evolution RTS Server Information$(NC)"
	@echo "=========================================="
	@echo "Project: $(PROJECT_NAME)"
	@echo "Description: 24/7 Evolution RTS server on Railway.app"
	@echo ""
	@echo "$(GREEN)Repository:$(NC)"
	@echo "  Game: https://github.com/EvolutionRTS/Evolution-RTS"
	@echo "  Engine: https://github.com/spring/spring"
	@echo ""
	@echo "$(GREEN)Documentation:$(NC)"
	@echo "  Game: https://www.evolutionrts.info"
	@echo "  Engine: https://springrts.com/wiki"
	@echo "  Railway: https://docs.railway.app"
	@echo ""
	@echo "$(GREEN)Community:$(NC)"
	@echo "  Discord: https://discord.gg/WUbAs2f"
	@echo ""
	@echo "$(GREEN)Quick Commands:$(NC)"
	@echo "  make build    - Build Docker image"
	@echo "  make run      - Start server locally"
	@echo "  make deploy   - Deploy to Railway"
	@echo "  make logs     - View logs"
	@echo "  make ssh      - Access container"
	@echo "=========================================="

version: ## Show version information
	@echo "$(BLUE)Version Information$(NC)"
	@echo "Project: Evolution RTS Server"
	@echo "Version: 1.0.0"
	@echo "Updated: January 2025"
	@echo ""
	@if docker ps | grep -q $(CONTAINER_NAME); then \
		echo "$(GREEN)Docker Container:$(NC)"; \
		docker exec $(CONTAINER_NAME) sh -c "cd /spring/games/Evolution\ RTS && git log --oneline -1" 2>/dev/null || echo "  Unable to get version"; \
	fi

###############################################################################
# CI/CD targets (for automated pipelines)
###############################################################################
ci-build: ## CI: Build and test
	@echo "$(BLUE)CI: Building and testing...$(NC)"
	$(MAKE) build-no-cache
	$(MAKE) test
	@echo "$(GREEN)✓ CI build and test passed$(NC)"

ci-deploy: ## CI: Deploy (only if tests pass)
	@echo "$(BLUE)CI: Deploying...$(NC)"
	$(MAKE) ci-build
	$(MAKE) deploy
	@echo "$(GREEN)✓ CI deployment complete$(NC)"

.PHONY: all-commands
all-commands: ## List all make targets
	@echo "$(BLUE)All Available Commands:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-30s$(NC) %s\n", $$1, $$2}'
