.PHONY: help up down build rebuild ps logs stop start clean fclean re

# Colors for output
GREEN  := \033[0;32m
YELLOW := \033[0;33m
BLUE   := \033[0;34m
RED    := \033[0;31m
NC     := \033[0m

# Docker variables
COMPOSE_FILE := srcs/docker-compose.yml
COMPOSE_CMD  := docker-compose -f $(COMPOSE_FILE)

# Default target
help:
	@echo "$(BLUE)╔═══════════════════════════════════════════════════════════╗$(NC)"
	@echo "$(BLUE)║          Inception - Docker Compose Makefile              ║$(NC)"
	@echo "$(BLUE)╚═══════════════════════════════════════════════════════════╝$(NC)"
	@echo ""
	@echo "$(GREEN)Main Commands:$(NC)"
	@echo "  $(YELLOW)make up$(NC)          - Build and start all containers (detached mode)"
	@echo "  $(YELLOW)make down$(NC)        - Stop all running containers"
	@echo "  $(YELLOW)make down-v$(NC)      - Stop containers and remove volumes"
	@echo "  $(YELLOW)make rebuild$(NC)     - Rebuild images and start containers"
	@echo "  $(YELLOW)make re$(NC)          - Full cleanup and restart (like fclean + up)"
	@echo ""
	@echo "$(GREEN)Build Commands:$(NC)"
	@echo "  $(YELLOW)make build$(NC)       - Build all Docker images"
	@echo "  $(YELLOW)make build-nginx$(NC) - Build only Nginx image"
	@echo "  $(YELLOW)make build-wp$(NC)    - Build only WordPress image"
	@echo "  $(YELLOW)make build-db$(NC)    - Build only MariaDB image"
	@echo ""
	@echo "$(GREEN)Monitoring Commands:$(NC)"
	@echo "  $(YELLOW)make ps$(NC)          - Show status of all containers"
	@echo "  $(YELLOW)make logs$(NC)        - Show live logs from all services"
	@echo "  $(YELLOW)make logs-nginx$(NC)  - Show Nginx logs"
	@echo "  $(YELLOW)make logs-wp$(NC)     - Show WordPress logs"
	@echo "  $(YELLOW)make logs-db$(NC)     - Show MariaDB logs"
	@echo "  $(YELLOW)make stats$(NC)       - Show container resource usage"
	@echo ""
	@echo "$(GREEN)Container Management:$(NC)"
	@echo "  $(YELLOW)make start$(NC)       - Start stopped containers"
	@echo "  $(YELLOW)make stop$(NC)        - Stop running containers (preserve data)"
	@echo "  $(YELLOW)make restart$(NC)     - Restart all containers"
	@echo "  $(YELLOW)make shell-wp$(NC)    - Open bash in WordPress container"
	@echo "  $(YELLOW)make shell-db$(NC)    - Open bash in MariaDB container"
	@echo "  $(YELLOW)make shell-nginx$(NC) - Open bash in Nginx container"
	@echo ""
	@echo "$(GREEN)Cleanup Commands:$(NC)"
	@echo "  $(YELLOW)make clean$(NC)       - Remove stopped containers"
	@echo "  $(YELLOW)make fclean$(NC)      - Remove all containers, images, and volumes"
	@echo "  $(YELLOW)make prune$(NC)       - Clean unused Docker resources"
	@echo ""
	@echo "$(GREEN)Utility Commands:$(NC)"
	@echo "  $(YELLOW)make help$(NC)        - Show this help message"
	@echo "  $(YELLOW)make status$(NC)      - Quick status check"
	@echo ""

# ╔═══════════════════════════════════════════════════════════╗
# ║                   MAIN COMMANDS                           ║
# ╚═══════════════════════════════════════════════════════════╝

up:
	@echo "$(GREEN)[+] Starting Inception services...$(NC)"
	@$(COMPOSE_CMD) up -d
	@echo "$(GREEN)[✓] Services started successfully!$(NC)"
	@echo "$(YELLOW)Waiting for initialization...$(NC)"
	@sleep 5
	@$(MAKE) status

down:
	@echo "$(YELLOW)[-] Stopping all services...$(NC)"
	@$(COMPOSE_CMD) down
	@echo "$(GREEN)[✓] Services stopped.$(NC)"

down-v:
	@echo "$(RED)[-] Stopping services and removing volumes...$(NC)"
	@$(COMPOSE_CMD) down -v
	@echo "$(GREEN)[✓] Services and volumes removed.$(NC)"

rebuild:
	@echo "$(GREEN)[+] Rebuilding images and starting services...$(NC)"
	@$(COMPOSE_CMD) up -d --build
	@echo "$(GREEN)[✓] Services rebuilt and started!$(NC)"
	@sleep 5
	@$(MAKE) status

re: fclean up
	@echo "$(GREEN)[✓] Full restart complete!$(NC)"

# ╔═══════════════════════════════════════════════════════════╗
# ║                   BUILD COMMANDS                          ║
# ╚═══════════════════════════════════════════════════════════╝

build:
	@echo "$(GREEN)[+] Building all Docker images...$(NC)"
	@$(COMPOSE_CMD) build
	@echo "$(GREEN)[✓] Images built successfully!$(NC)"

build-nginx:
	@echo "$(GREEN)[+] Building Nginx image...$(NC)"
	@$(COMPOSE_CMD) build nginx
	@echo "$(GREEN)[✓] Nginx image built!$(NC)"

build-wp:
	@echo "$(GREEN)[+] Building WordPress image...$(NC)"
	@$(COMPOSE_CMD) build wordpress
	@echo "$(GREEN)[✓] WordPress image built!$(NC)"

build-db:
	@echo "$(GREEN)[+] Building MariaDB image...$(NC)"
	@$(COMPOSE_CMD) build mariadb
	@echo "$(GREEN)[✓] MariaDB image built!$(NC)"

# ╔═══════════════════════════════════════════════════════════╗
# ║                   MONITORING COMMANDS                     ║
# ╚═══════════════════════════════════════════════════════════╝

ps:
	@echo "$(BLUE)╔═ Container Status ═╗$(NC)"
	@$(COMPOSE_CMD) ps
	@echo "$(BLUE)╚════════════════════╝$(NC)"

logs:
	@$(COMPOSE_CMD) logs -f

logs-nginx:
	@$(COMPOSE_CMD) logs -f nginx

logs-wp:
	@$(COMPOSE_CMD) logs -f wordpress

logs-db:
	@$(COMPOSE_CMD) logs -f mariadb

stats:
	@docker stats --no-stream

status:
	@echo "$(BLUE)╔═ Quick Status Check ═╗$(NC)"
	@echo ""
	@echo "$(GREEN)Container Status:$(NC)"
	@$(COMPOSE_CMD) ps --services --filter "status=running" | wc -l | xargs -I {} echo "  {} services running"
	@echo ""
	@echo "$(GREEN)Network:$(NC)"
	@docker network inspect srcs_inception --format="IP: {{range .Containers}}{{.IPv4Address}} {{end}}" 2>/dev/null || echo "  Network not yet created"
	@echo ""
	@echo "$(GREEN)Volumes:$(NC)"
	@ls -lah /Users/dev/data/wordpress 2>/dev/null | head -2 | tail -1 | awk '{print "  WordPress: "$$9" files"}' || echo "  WordPress: not mounted"
	@ls -lah /Users/dev/data/mariadb 2>/dev/null | head -2 | tail -1 | awk '{print "  MariaDB: "$$9" files"}' || echo "  MariaDB: not mounted"
	@echo ""
	@echo "$(BLUE)╚═══════════════════════╝$(NC)"

# ╔═══════════════════════════════════════════════════════════╗
# ║                   CONTAINER MANAGEMENT                    ║
# ╚═══════════════════════════════════════════════════════════╝

start:
	@echo "$(GREEN)[+] Starting containers...$(NC)"
	@$(COMPOSE_CMD) start
	@echo "$(GREEN)[✓] Containers started!$(NC)"

stop:
	@echo "$(YELLOW)[-] Stopping containers...$(NC)"
	@$(COMPOSE_CMD) stop
	@echo "$(GREEN)[✓] Containers stopped.$(NC)"

restart:
	@echo "$(YELLOW)[*] Restarting all containers...$(NC)"
	@$(COMPOSE_CMD) restart
	@echo "$(GREEN)[✓] Containers restarted!$(NC)"

shell-wp:
	@echo "$(BLUE)[*] Opening bash in WordPress container...$(NC)"
	@$(COMPOSE_CMD) exec wordpress /bin/bash

shell-db:
	@echo "$(BLUE)[*] Opening bash in MariaDB container...$(NC)"
	@$(COMPOSE_CMD) exec mariadb /bin/bash

shell-nginx:
	@echo "$(BLUE)[*] Opening bash in Nginx container...$(NC)"
	@$(COMPOSE_CMD) exec nginx /bin/bash

# ╔═══════════════════════════════════════════════════════════╗
# ║                   CLEANUP COMMANDS                        ║
# ╚═══════════════════════════════════════════════════════════╝

clean:
	@echo "$(YELLOW)[*] Cleaning up stopped containers...$(NC)"
	@docker container prune -f --filter "label!=keep" || true
	@echo "$(GREEN)[✓] Cleanup complete.$(NC)"

fclean:
	@echo "$(RED)[!] Full cleanup: removing containers, images, and volumes...$(NC)"
	@$(COMPOSE_CMD) down -v
	@echo "$(RED)[!] Removing all Inception images...$(NC)"
	@docker rmi -f $$(docker images | grep -E 'srcs_|inception' | awk '{print $$3}') 2>/dev/null || true
	@echo "$(GREEN)[✓] Full cleanup complete!$(NC)"

prune:
	@echo "$(YELLOW)[*] Pruning unused Docker resources...$(NC)"
	@docker system prune -f --volumes
	@echo "$(GREEN)[✓] Prune complete.$(NC)"

# ╔═══════════════════════════════════════════════════════════╗
# ║                   UTILITY TARGETS                         ║
# ╚═══════════════════════════════════════════════════════════╝

validate:
	@echo "$(BLUE)[*] Validating Nginx configuration...$(NC)"
	@$(COMPOSE_CMD) exec nginx nginx -t
	@echo "$(GREEN)[✓] Nginx config is valid!$(NC)"

test-db:
	@echo "$(BLUE)[*] Testing database connection...$(NC)"
	@$(COMPOSE_CMD) exec wordpress mysql -h mariadb -u $$(grep SQL_USER srcs/.env | cut -d '=' -f2) -p$$(grep SQL_PASSWORD srcs/.env | cut -d '=' -f2) -e "SELECT 1;" 2>/dev/null && echo "$(GREEN)[✓] Database connection OK!$(NC)" || echo "$(RED)[✗] Database connection failed!$(NC)"

test-wp:
	@echo "$(BLUE)[*] Testing WordPress connectivity...$(NC)"
	@$(COMPOSE_CMD) exec wordpress wp --allow-root user list 2>/dev/null && echo "$(GREEN)[✓] WordPress is healthy!$(NC)" || echo "$(YELLOW)[!] WordPress still initializing...$(NC)"

info:
	@echo "$(BLUE)╔═ Project Information ═╗$(NC)"
	@echo "$(GREEN)Project:$(NC) Inception (42 Curriculum)"
	@echo "$(GREEN)Compose File:$(NC) $(COMPOSE_FILE)"
	@echo "$(GREEN)Data Directory:$(NC) /Users/dev/data/"
	@echo "$(GREEN)Services:$(NC) Nginx, WordPress, MariaDB"
	@echo "$(BLUE)╚════════════════════════╝$(NC)"

# ╔═══════════════════════════════════════════════════════════╗
# ║                   .PHONY DECLARATION                      ║
# ╚═══════════════════════════════════════════════════════════╝

.PHONY: help up down down-v rebuild re build build-nginx build-wp build-db ps logs logs-nginx logs-wp logs-db stats status start stop restart shell-wp shell-db shell-nginx clean fclean prune validate test-db test-wp info
