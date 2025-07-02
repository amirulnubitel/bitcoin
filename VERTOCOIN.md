# Vertocoin (VTO) - High-Speed Cryptocurrency

Vertocoin is a fast, secure cryptocurrency based on Bitcoin Core technology with optimizations for rapid transaction processing.

## Key Features

- **Name**: Vertocoin
- **Ticker**: VTO
- **Currency Symbol**: VTO
- **Maximum Supply**: 50,000,000,000 VTO
- **Block Time**: 30 seconds
- **Initial Distribution**: 2,000,000,000 VTO (Genesis block)
- **Block Reward**: 1000 VTO
- **Halving Interval**: Every 4 years (4,204,800 blocks)
- **Genesis Date**: July 1st, 2025
- **Consensus Algorithm**: Proof of Work (PoW)
- **Website**: vertomax.com

## Network Details

- **Main Network Port**: 9333
- **RPC Port**: 9332
- **Address Prefix**: V (for VTO addresses)
- **Bech32 Prefix**: vto
- **Message Start**: 0xf0d9b7d2

## Technical Specifications

### Mining

- **Algorithm**: SHA-256 (Bitcoin-compatible)
- **Target Block Time**: 30 seconds
- **Difficulty Adjustment**: Every 60 blocks (30 minutes)
- **Initial Block Reward**: 1000 VTO
- **Reward Halving**: Every 4,204,800 blocks (~4 years)

### Supply Economics

- **Initial Supply**: 2,000,000,000 VTO (Genesis allocation)
- **Mining Rewards**: 1000 VTO per block, halving every 4 years
- **Maximum Supply**: 50,000,000,000 VTO (hard cap)
- **Inflation Rate**: Decreasing over time due to halving mechanism

### Block Details

- **Block Size**: Bitcoin-compatible (up to 4MB with SegWit)
- **Block Time**: 30 seconds (2x faster than Bitcoin)
- **Transactions per Second**: Higher capacity due to faster blocks
- **Confirmation Speed**: 30 seconds for 1 confirmation, 5 minutes for 10 confirmations

## Build Instructions

### Prerequisites

- CMake 3.21 or higher
- C++20 compatible compiler (LLVM/Clang 20+ recommended on macOS)
- Python 3.10+

### Building

1. **Configure the build:**

   ```bash
   cmake -B build_dev_mode -DCMAKE_BUILD_TYPE=Debug
   ```

2. **Compile:**

   ```bash
   cmake --build build_dev_mode --parallel 4
   ```

3. **Install (optional):**
   ```bash
   cmake --install build_dev_mode
   ```

### Configuration

1. Create a configuration file (vertocoin.conf):

   ```
   port=9333
   rpcport=9332
   rpcuser=vtouser
   rpcpassword=your_secure_password
   txindex=1
   ```

2. Place the configuration file in your data directory:
   - Linux: `~/.vertocoin/`
   - macOS: `~/Library/Application Support/Vertocoin/`
   - Windows: `%APPDATA%\Vertocoin\`

## Network Architecture

### Seed Nodes

- seed1.vertomax.com
- seed2.vertomax.com
- seed3.vertomax.com

### Features Enabled from Genesis

- SegWit (Segregated Witness)
- BIP34 (Block height in coinbase)
- BIP65 (OP_CHECKLOCKTIMEVERIFY)
- BIP66 (Strict DER signatures)
- CSV (OP_CHECKSEQUENCEVERIFY)
- Taproot (Schnorr signatures and Tapscript)

## Development Status

This is an experimental implementation based on Bitcoin Core. The network parameters have been configured for Vertocoin specifications but require proper testing and genesis block mining before production use.

### Todo Items

1. Mine proper genesis block with correct difficulty
2. Set up DNS seed infrastructure
3. Complete network testing
4. Deploy initial seed nodes
5. Conduct security audits

## Differences from Bitcoin

| Feature        | Bitcoin    | Vertocoin  |
| -------------- | ---------- | ---------- |
| Block Time     | 10 minutes | 30 seconds |
| Max Supply     | 21M BTC    | 50B VTO    |
| Initial Reward | 50 BTC     | 1000 VTO   |
| Genesis Coins  | 0          | 2B VTO     |
| Halving Period | ~4 years   | 4 years    |
| Port           | 8333       | 9333       |
| Address Prefix | 1 or 3     | V          |

## License

Vertocoin is released under the terms of the MIT license. See [COPYING](COPYING) for more information or see https://opensource.org/license/MIT.

## Disclaimer

This is experimental software. Use at your own risk. The network is not yet production-ready and requires additional development and testing.
