# VertoCoin Docker Setup

This directory contains Docker configuration files for running VertoCoin nodes in containerized environments.

## Quick Start

1. **Setup the environment:**

   ```bash
   ./docker-vertocoin.sh setup
   ```

2. **Build the Docker image:**

   ```bash
   ./docker-vertocoin.sh build
   ```

3. **Start the mainnet node:**

   ```bash
   ./docker-vertocoin.sh start
   ```

4. **Check the status:**
   ```bash
   ./docker-vertocoin.sh status
   ```

## Files Overview

- **`Dockerfile`** - Multi-stage Docker image for VertoCoin
- **`docker-compose.yml`** - Docker Compose configuration
- **`.dockerignore`** - Files to exclude from Docker build context
- **`docker-vertocoin.sh`** - Management script for common operations

## Available Services

### VertoCoin Core (Mainnet)

- **Container Name:** `vertocoin-core`
- **Ports:**
  - `9332` - RPC port
  - `9333` - P2P port
  - `28332-28335` - ZMQ notification ports
- **Data Volume:** `./data/mainnet`

### VertoCoin Regtest (Development)

- **Container Name:** `vertocoin-regtest`
- **Ports:**
  - `19443` - Regtest RPC port
  - `19444` - Regtest P2P port
- **Data Volume:** `./data/regtest`

## Management Commands

### Basic Operations

```bash
# Build the Docker image
./docker-vertocoin.sh build

# Start mainnet node
./docker-vertocoin.sh start

# Start regtest node (for development)
./docker-vertocoin.sh start-regtest

# Stop all services
./docker-vertocoin.sh stop

# Restart mainnet node
./docker-vertocoin.sh restart

# Show status
./docker-vertocoin.sh status
```

### Logs and Monitoring

```bash
# View logs (mainnet)
./docker-vertocoin.sh logs

# Follow logs in real-time
./docker-vertocoin.sh logs -f

# View regtest logs
./docker-vertocoin.sh logs-regtest
```

### CLI Access

```bash
# Access mainnet CLI
./docker-vertocoin.sh cli getblockchaininfo

# Access regtest CLI
./docker-vertocoin.sh cli-regtest getblockchaininfo

# Generate blocks in regtest
./docker-vertocoin.sh cli-regtest generatetoaddress 10 $(./docker-vertocoin.sh cli-regtest getnewaddress)
```

### Cleanup

```bash
# Remove containers and volumes
./docker-vertocoin.sh clean
```

## Manual Docker Commands

If you prefer using Docker commands directly:

```bash
# Build image
docker-compose build

# Start mainnet
docker-compose up -d vertocoin-core

# Start regtest
docker-compose --profile regtest up -d vertocoin-regtest

# View logs
docker-compose logs -f vertocoin-core

# Execute CLI commands
docker-compose exec vertocoin-core vertocoin-cli getblockchaininfo

# Stop services
docker-compose down
```

## Configuration

The VertoCoin configuration is stored in `vertocoin.conf`. Key settings include:

- **Network Ports:** 9333 (P2P), 9332 (RPC)
- **ZMQ Notifications:** Enabled on ports 28332-28335
- **Indexing:** Transaction and block filter indexes enabled
- **Performance:** Optimized cache and thread settings

## Data Persistence

Blockchain data is persisted in local directories:

- `./data/mainnet/` - Mainnet blockchain data
- `./data/regtest/` - Regtest blockchain data

## Networking

Services communicate through a custom Docker network (`vertocoin-network`) with subnet `172.50.0.0/16`.

## Health Checks

Both services include health checks that verify the node is responding to RPC calls:

- **Interval:** 30 seconds
- **Timeout:** 10 seconds
- **Retries:** 3 attempts

## Development Profiles

Use Docker Compose profiles to run different configurations:

```bash
# Run only mainnet
docker-compose up -d

# Run regtest for development
docker-compose --profile regtest up -d

# Run with monitoring (when enabled)
docker-compose --profile monitoring up -d
```

## Security Considerations

- RPC credentials are configured in `vertocoin.conf`
- Consider changing default passwords for production use
- Firewall rules should restrict access to RPC ports
- Data directories should have appropriate permissions

## Troubleshooting

### Container won't start

```bash
# Check logs
./docker-vertocoin.sh logs

# Check container status
docker-compose ps

# Rebuild image
./docker-vertocoin.sh build
```

### Permission issues

```bash
# Fix data directory permissions
sudo chown -R 1000:1000 data/
```

### Network connectivity issues

```bash
# Check if ports are available
netstat -tulpn | grep -E ':(9332|9333|19443|19444)'

# Test RPC connection
curl -u vertomax:Vertomax2025 -X POST -H 'Content-Type: application/json' \
  -d '{"jsonrpc":"1.0","id":"test","method":"getblockchaininfo","params":[]}' \
  http://localhost:9332/
```

## Production Deployment

For production environments, consider:

1. **Change default credentials** in `vertocoin.conf`
2. **Use Docker secrets** for sensitive configuration
3. **Configure proper backup** for blockchain data
4. **Set up monitoring** and alerting
5. **Use reverse proxy** for secure external access
6. **Implement log rotation** to manage disk space

## Contributing

When modifying the Docker setup:

1. Test changes in regtest mode first
2. Update this documentation
3. Verify the build process works on clean systems
4. Test upgrade scenarios with existing data
