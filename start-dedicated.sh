#!/bin/bash
###############################################################################
# Zero-K Dedicated Server Startup Script
# Railway.app Deployment - Advanced Configuration
###############################################################################

set -e

###############################################################################
# Configuration Variables
###############################################################################

# Server configuration
SERVER_NAME="${SERVER_NAME:-Persistent Zero-K MMO World}"
MAX_PLAYERS="${MAX_PLAYERS:-16}"
GAME_PORT="${PORT:-8200}"
LOBBY_PORT="${LOBBY_PORT:-8452}"
GAME_MOD="${GAME_MOD:-Zero-K}"

# Persistence paths
PERSISTENT_DIR="/data/persistent"
REPLAYS_DIR="${PERSISTENT_DIR}/replays"
LOGS_DIR="${PERSISTENT_DIR}/logs"
CONFIG_DIR="${PERSISTENT_DIR}/config"
SPRING_DIR="/spring"

# Spring executable
SPRING_BIN="${SPRING_DIR}/spring-dedicated"

# Health check variables
HEALTH_CHECK_INTERVAL=30
HEALTH_CHECK_TIMEOUT=10

###############################################################################
# Logging Functions
###############################################################################

log() {
    local level=$1
    shift
    local message="$@"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" | tee -a "${LOGS_DIR}/startup.log"
}

log_info() {
    log "INFO" "$@"
}

log_warn() {
    log "WARN" "$@"
}

log_error() {
    log "ERROR" "$@"
}

log_success() {
    log "SUCCESS" "$@"
}

###############################################################################
# Initialization Functions
###############################################################################

initialize_directories() {
    log_info "Initializing directories..."

    mkdir -p "${REPLAYS_DIR}"
    mkdir -p "${LOGS_DIR}"
    mkdir -p "${CONFIG_DIR}"
    mkdir -p "${SPRING_DIR}/cache"

    log_success "Directories initialized successfully"
}

check_dependencies() {
    log_info "Checking dependencies..."

    # Check if Spring binary exists
    if [ ! -f "${SPRING_BIN}" ]; then
        log_error "Spring dedicated binary not found at ${SPRING_BIN}"
        exit 1
    fi

    # Make sure it's executable
    chmod +x "${SPRING_BIN}"

    # Check for required libraries
    if ! ldd "${SPRING_BIN}" >/dev/null 2>&1; then
        log_warn "Some library dependencies might be missing"
    fi

    log_success "Dependencies check completed"
}

setup_persistence() {
    log_info "Setting up persistent storage..."

    # Create symlinks for persistence
    ln -sf "${REPLAYS_DIR}" "${SPRING_DIR}/replays"
    ln -sf "${LOGS_DIR}" "${SPRING_DIR}/logs"

    # Copy default config if persistent config doesn't exist
    if [ ! -f "${CONFIG_DIR}/gameconfig.txt" ]; then
        log_info "Creating default game configuration..."
        cp /spring/gameconfig.txt "${CONFIG_DIR}/gameconfig.txt"
    fi

    # Update configuration with environment variables
    update_config_with_env_vars

    log_success "Persistence setup completed"
}

update_config_with_env_vars() {
    log_info "Updating configuration with environment variables..."

    local config_file="${CONFIG_DIR}/gameconfig.txt"

    # Update server name
    sed -i "s/^Name = .*/Name = ${SERVER_NAME}/" "${config_file}"

    # Update max players
    sed -i "s/^MaxPlayers = .*/MaxPlayers = ${MAX_PLAYERS}/" "${config_file}"

    # Update port
    sed -i "s/^Port = .*/Port = ${GAME_PORT}/" "${config_file}"

    log_success "Configuration updated with environment variables"
}

###############################################################################
# Server Management Functions
###############################################################################

generate_server_script() {
    log_info "Generating server startup script..."

    local script_file="${SPRING_DIR}/start_script.txt"

    cat > "${script_file}" << EOF
[GAME]
{
    GameType = ${GAME_MOD};
    MapName = Comet Catcher Remake;
    StartPosType = 2;
    [MODOPTIONS]
    {
    };
    [restrict]
    {
    };
}
EOF

    log_success "Server script generated"
}

cleanup_old_files() {
    log_info "Cleaning up old files..."

    # Remove old replay files beyond retention period
    if [ -n "${REPLAY_RETENTION_DAYS:-30}" ]; then
        find "${REPLAYS_DIR}" -name "*.ssf" -type f -mtime +${REPLAY_RETENTION_DAYS} -delete
    fi

    # Clean up old log files
    find "${LOGS_DIR}" -name "*.log" -type f -mtime +7 -delete

    log_success "Old files cleaned up"
}

###############################################################################
# Health Check Functions
###############################################################################

start_health_check() {
    log_info "Starting health check monitoring..."

    while true; do
        sleep ${HEALTH_CHECK_INTERVAL}

        if ! pgrep -f "spring-dedicated" > /dev/null; then
            log_error "Server process not found! Attempting restart..."
            break
        fi

        # Check if server is responsive on the game port
        if timeout ${HEALTH_CHECK_TIMEOUT} bash -c "cat < /dev/null > /dev/udp/127.0.0.1/${GAME_PORT}" 2>/dev/null; then
            log_info "Health check passed"
        else
            log_warn "Health check warning - server might be unresponsive"
        fi
    done

    # If we get here, server died and we need to restart
    log_error "Server died unexpectedly, performing cleanup..."
    cleanup_and_restart
}

###############################################################################
# Signal Handling
###############################################################################

setup_signal_handlers() {
    log_info "Setting up signal handlers..."

    trap 'log_info "Received SIGTERM, shutting down gracefully..."; shutdown_server; exit 0' TERM
    trap 'log_info "Received SIGINT, shutting down gracefully..."; shutdown_server; exit 0' INT
    trap 'log_info "Received SIGHUP, reloading configuration..."; reload_config;' HUP
}

shutdown_server() {
    log_info "Initiating graceful shutdown..."

    # Find and kill the Spring process
    local pid=$(pgrep -f "spring-dedicated" || true)
    if [ -n "${pid}" ]; then
        log_info "Sending SIGTERM to server process ${pid}"
        kill -TERM "${pid}"

        # Wait up to 30 seconds for graceful shutdown
        local timeout=30
        while kill -0 "${pid}" 2>/dev/null && [ $timeout -gt 0 ]; do
            sleep 1
            timeout=$((timeout - 1))
        done

        # Force kill if still running
        if kill -0 "${pid}" 2>/dev/null; then
            log_warn "Forcing server shutdown..."
            kill -KILL "${pid}"
        fi
    fi

    log_success "Server shutdown completed"
}

reload_config() {
    log_info "Reloading configuration..."

    # Update configuration with current environment variables
    update_config_with_env_vars

    # Note: Spring RTS doesn't support hot reload of all configs
    # Some changes require server restart
    log_warn "Some configuration changes may require server restart"
}

cleanup_and_restart() {
    log_info "Performing cleanup before restart..."

    # Clean up temporary files
    rm -f "${SPRING_DIR}"/*.tmp

    # Archive logs if needed
    if [ -f "${LOGS_DIR}/server.log" ]; then
        mv "${LOGS_DIR}/server.log" "${LOGS_DIR}/server.log.$(date +%Y%m%d_%H%M%S)"
    fi

    log_info "Restarting server..."
    start_server
}

###############################################################################
# Server Startup
###############################################################################

start_server() {
    log_info "Starting Zero-K dedicated server..."

    # Display server information
    echo "=========================================="
    echo "Zero-K Dedicated Server"
    echo "=========================================="
    echo "Server Name: ${SERVER_NAME}"
    echo "Max Players: ${MAX_PLAYERS}"
    echo "Game Port: ${GAME_PORT}/UDP"
    echo "Lobby Port: ${LOBBY_PORT}/TCP"
    echo "Game Mod: ${GAME_MOD}"
    echo "=========================================="

    # Generate server script
    generate_server_script

    # Prepare Spring arguments
    local spring_args=(
        --config="${SPRING_DIR}/springrc-dedicated.txt"
        --isolated
        --game="${GAME_MOD}"
        --script="${SPRING_DIR}/start_script.txt"
    )

    # Change to Spring directory
    cd "${SPRING_DIR}"

    # Start health check in background
    start_health_check &
    local health_check_pid=$!

    # Start the server
    log_success "Server starting with PID $$"

    # Run Spring and capture output
    "${SPRING_BIN}" "${spring_args[@]}" 2>&1 | tee -a "${LOGS_DIR}/server.log" &
    local server_pid=$!

    # Wait for server process
    wait ${server_pid}
    local exit_code=$?

    # Clean up health check
    kill ${health_check_pid} 2>/dev/null || true

    log_error "Server exited with code ${exit_code}"

    # If server crashed, attempt restart
    if [ ${exit_code} -ne 0 ]; then
        log_info "Attempting automatic restart in 30 seconds..."
        sleep 30
        start_server
    fi
}

###############################################################################
# Main Execution
###############################################################################

main() {
    echo "=========================================="
    echo "Zero-K Dedicated Server Startup"
    echo "Railway.app Deployment"
    echo "=========================================="

    # Wait for filesystem to be ready
    log_info "Waiting for filesystem to be ready..."
    sleep 3

    # Run initialization
    initialize_directories
    check_dependencies
    setup_persistence
    cleanup_old_files

    # Set up signal handlers
    setup_signal_handlers

    # Start the server
    start_server
}

# Run main function
main
