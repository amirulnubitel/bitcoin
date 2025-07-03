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
   bsdmainutils \
   cmake \
   ccache \
   python3 \
   curl \
   automake \
   autoconf \
   make \
   patch \
   bison \
   g++ \
   ninja-build \
   xz-utils \
   git \
   libtool \
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
   libcapnp-dev \
   capnproto \
   && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy source code
COPY . .

# Build dependencies first (if using depends system)
RUN cd depends && make -j$(nproc) NO_QT=1

# Configure and build VertoCoin
RUN cmake -B build \
   -DCMAKE_TOOLCHAIN_FILE=/app/depends/x86_64-pc-linux-gnu/toolchain.cmake \
   -DCMAKE_BUILD_TYPE=Release \
   -DCMAKE_CXX_FLAGS="-Wno-error" \
   -DCMAKE_C_FLAGS="-Wno-error" \
   -DBUILD_TX=ON \
   -DBUILD_UTIL=ON \
   -DWITH_ZMQ=ON \
   -DWITH_USDT=OFF \
   -DWITH_WALLET=ON \
   -DBUILD_WALLET_TOOL=ON \
   -DWITH_CCACHE=ON \
   -DENABLE_IPC=OFF \
   -DBUILD_TESTS=OFF \
   -DWITH_GUI=OFF \
   -DENABLE_TESTS=OFF \
   -DENABLE_BENCH=ON

# RUN cmake -B build \
# -DWITH_SQLITE=ON \
# -DWITH_BDB=ON \
# -DWITH_MINIUPNPC=ON \
# -DWITH_NATPMP=ON \
# -DWITH_QRENCODE=ON \

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
RUN groupadd -r vertocoin && useradd -r -g vertocoin -m -d /home/vertocoin vertocoin

# Create data directory with proper permissions
# RUN mkdir -p /home/vertocoin/.vertocoin/wallets && \
#    chown -R vertocoin:vertocoin /home/vertocoin && \
#    chmod -R 755 /home/vertocoin/.vertocoin

# Copy binaries from builder stage
COPY --from=builder /app/build/bin/bitcoind /usr/local/bin/vertocoind
COPY --from=builder /app/build/bin/bitcoin-cli /usr/local/bin/vertocoin-cli
COPY --from=builder /app/build/bin/bitcoin-tx /usr/local/bin/vertocoin-tx
COPY --from=builder /app/build/bin/bitcoin-util /usr/local/bin/vertocoin-util
COPY --from=builder /app/build/bin/bitcoin-wallet /usr/local/bin/vertocoin-wallet

# Copy configuration file and set proper ownership
COPY --from=builder --chown=vertocoin:vertocoin /app/vertocoin.conf /home/vertocoin/.vertocoin/vertocoin.conf

# Copy and setup entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

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
CMD ["vertocoind -conf=/home/vertocoin/.vertocoin/vertocoin.conf"]
