# Multi-stage Dockerfile for VertoCoin (VTO)
# Based on Bitcoin Core with VertoCoin modifications

# Build stage
FROM ubuntu:22.04 AS builder

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install build dependencies
RUN apt-get update && apt-get install -y \
   build-essential \
   cmake \
   pkgconf \
   python3 \
   curl \
   make \
   patch \
   bison \
   g++ \
   ninja-build \
   xz-utils \
   git \
   ca-certificates \
   libsqlite3-dev \
   libboost-all-dev \
   libevent-dev \
   libminiupnpc-dev \
   libnatpmp-dev \
   libzmq3-dev \
   qtbase5-dev \
   qttools5-dev-tools \
   libqrencode-dev \
   libdb5.3++-dev \
   libssl-dev \
   pkg-config \
   && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy source code
COPY . .

# Build dependencies first (if using depends system)
RUN cd depends && make -j$(nproc) NO_QT=1

# Configure and build VertoCoin
RUN cmake -B build \
   -DCMAKE_BUILD_TYPE=Release \
   -DBUILD_TESTS=OFF \
   -DWITH_GUI=OFF \
   -DWITH_WALLET=ON \
   -DENABLE_TESTS=OFF \
   -DENABLE_BENCH=OFF

# Build the project
RUN cmake --build build -j$(nproc)

# Runtime stage
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
   ca-certificates \
   gosu \
   && rm -rf /var/lib/apt/lists/*

# Create vertocoin user
RUN groupadd -r vertocoin && useradd -r -g vertocoin vertocoin

# Create data directory
RUN mkdir -p /home/vertocoin/.vertocoin && \
   chown vertocoin:vertocoin /home/vertocoin/.vertocoin

# Copy binaries from builder stage
COPY --from=builder /app/build/src/bitcoind /usr/local/bin/
COPY --from=builder /app/build/src/bitcoin-cli /usr/local/bin/
COPY --from=builder /app/build/src/bitcoin-tx /usr/local/bin/
COPY --from=builder /app/build/src/bitcoin-util /usr/local/bin/
COPY --from=builder /app/build/src/bitcoin-wallet /usr/local/bin/

# Copy configuration file
COPY vertocoin.conf /home/vertocoin/.vertocoin/vertocoin.conf
RUN chown vertocoin:vertocoin /home/vertocoin/.vertocoin/vertocoin.conf

# Create entrypoint script
RUN echo '#!/bin/bash\n\
   set -e\n\
   \n\
   # If running as root, drop privileges to vertocoin user\n\
   if [ "$(id -u)" = "0" ]; then\n\
   exec gosu vertocoin "$0" "$@"\n\
   fi\n\
   \n\
   # Default to running bitcoind if no command specified\n\
   if [ "$#" -eq 0 ]; then\n\
   exec bitcoind -conf=/home/vertocoin/.vertocoin/vertocoin.conf -datadir=/home/vertocoin/.vertocoin\n\
   else\n\
   exec "$@"\n\
   fi' > /usr/local/bin/docker-entrypoint.sh && \
   chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose ports
# Main network port: 9333
# RPC port: 9332
# ZMQ ports: 28332-28335
# Regtest ports: 19443-19444
EXPOSE 9332 9333 19443 19444 28332 28333 28334 28335

# Set data directory volume
VOLUME ["/home/vertocoin/.vertocoin"]

# Set working directory
WORKDIR /home/vertocoin

# Use entrypoint script
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Default command
CMD ["bitcoind"]
