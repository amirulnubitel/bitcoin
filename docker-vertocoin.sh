#!/bin/bash
# VertoCoin Docker Management Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_usage() {
    echo "VertoCoin Docker Management Script"
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  build           Build the VertoCoin Docker image"
    echo "  start           Start VertoCoin mainnet node"
    echo "  start-regtest   Start VertoCoin regtest node"
    echo "  stop            Stop all VertoCoin services"
    echo "  restart         Restart VertoCoin mainnet node"
    echo "  logs            Show logs for mainnet node"
    echo "  logs-regtest    Show logs for regtest node"
    echo "  cli             Access VertoCoin CLI (mainnet)"
    echo "  cli-regtest     Access VertoCoin CLI (regtest)"
    echo "  status          Show status of all services"
    echo "  clean           Remove containers and volumes"
    echo "  setup           Initial setup (create data directories)"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 start"
    echo "  $0 cli getblockchaininfo"
    echo "  $0 logs -f"
}

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create data directories
setup() {
    log "Setting up VertoCoin Docker environment..."
    
    # Create data directories
    mkdir -p data/mainnet data/regtest
    
    # Set permissions
    sudo chown -R 1000:1000 data/
    
    log "Setup complete!"
}

# Build Docker image
build() {
    log "Building VertoCoin Docker image..."
    docker compose build vertocoin-core
    log "Build complete!"
}

# Start services
start() {
    log "Starting VertoCoin mainnet node..."
    docker compose up -d vertocoin-core
    log "VertoCoin mainnet node started!"
}

# start_regtest() {
#     log "Starting VertoCoin regtest node..."
#     docker compose --profile regtest up -d vertocoin-regtest
#     log "VertoCoin regtest node started!"
# }

# Stop services
stop() {
    log "Stopping all VertoCoin services..."
    docker compose down
    log "All services stopped!"
}

# Restart services
restart() {
    log "Restarting VertoCoin mainnet node..."
    docker compose restart vertocoin-core
    log "VertoCoin mainnet node restarted!"
}

# Show logs
logs() {
    shift
    docker compose logs "$@" vertocoin-core
}

# logs_regtest() {
#     shift
#     docker compose logs "$@" vertocoin-regtest
# }

# CLI access
cli() {
    shift
    if [ $# -eq 0 ]; then
        # Interactive shell
        docker compose exec vertocoin-core bitcoin-cli -conf=/home/vertocoin/.vertocoin/vertocoin.conf
    else
        # Execute command
        docker compose exec vertocoin-core bitcoin-cli -conf=/home/vertocoin/.vertocoin/vertocoin.conf "$@"
    fi
}

# cli_regtest() {
#     shift
#     if [ $# -eq 0 ]; then
#         # Interactive shell
#         docker compose exec vertocoin-regtest bitcoin-cli -regtest -conf=/home/vertocoin/.vertocoin/vertocoin.conf
#     else
#         # Execute command
#         docker compose exec vertocoin-regtest bitcoin-cli -regtest -conf=/home/vertocoin/.vertocoin/vertocoin.conf "$@"
#     fi
# }

# Show status
status() {
    log "VertoCoin Services Status:"
    docker compose ps
    echo ""
    log "Health Status:"
    docker compose exec vertocoin-core bitcoin-cli -conf=/home/vertocoin/.vertocoin/vertocoin.conf getblockchaininfo 2>/dev/null || warn "Mainnet node not responding"
}

# Clean up
clean() {
    warn "This will remove all containers and volumes. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        log "Cleaning up VertoCoin Docker environment..."
        docker compose down -v
        docker image rm vertocoin:latest 2>/dev/null || true
        sudo rm -rf data/
        log "Cleanup complete!"
    else
        log "Cleanup cancelled."
    fi
}

# Main command handler
case "$1" in
    build)
        build
        ;;
    start)
        start
        ;;
    start-regtest)
        start_regtest
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    logs)
        logs "$@"
        ;;
    logs-regtest)
        logs_regtest "$@"
        ;;
    cli)
        cli "$@"
        ;;
    cli-regtest)
        cli_regtest "$@"
        ;;
    status)
        status
        ;;
    clean)
        clean
        ;;
    setup)
        setup
        ;;
    *)
        print_usage
        exit 1
        ;;
esac
