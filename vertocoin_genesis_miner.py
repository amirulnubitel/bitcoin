#!/usr/bin/env python3

import hashlib
import struct
import time

def hash256(s):
    return hashlib.sha256(hashlib.sha256(s).digest()).digest()

def mine_genesis_block(timestamp, merkle_root, bits):
    """
    Mine a genesis block by finding a valid nonce
    """
    version = 1
    prev_block = b'\x00' * 32
    
    print(f"Mining genesis block...")
    print(f"Timestamp: {timestamp} ({time.ctime(timestamp)})")
    print(f"Merkle root: {merkle_root.hex()}")
    print(f"Target bits: 0x{bits:08x}")
    
    target_max = 0x00000000FFFF0000000000000000000000000000000000000000000000000000
    target = target_max >> (bits >> 24)
    
    nonce = 0
    while nonce < 0xFFFFFFFF:
        # Build block header
        header = struct.pack('<I', version)           # Version
        header += prev_block                          # Previous block hash
        header += merkle_root                         # Merkle root
        header += struct.pack('<I', timestamp)        # Timestamp
        header += struct.pack('<I', bits)             # Target bits
        header += struct.pack('<I', nonce)            # Nonce
        
        # Calculate hash
        block_hash = hash256(header)
        hash_int = int.from_bytes(block_hash[::-1], 'big')
        
        if hash_int < target:
            print(f"Found valid nonce: {nonce}")
            print(f"Block hash: {block_hash[::-1].hex()}")
            return nonce, block_hash[::-1]
        
        if nonce % 100000 == 0:
            print(f"Tried nonces: {nonce:,}")
        
        nonce += 1
    
    print("No valid nonce found in range!")
    return None, None

def create_genesis_transaction():
    """
    Create the genesis transaction with Vertocoin parameters
    """
    # Transaction version
    tx = struct.pack('<I', 1)
    
    # Input count
    tx += b'\x01'
    
    # Input (coinbase)
    tx += b'\x00' * 32  # Previous output hash (null)
    tx += struct.pack('<I', 0xFFFFFFFF)  # Previous output index (coinbase marker)
    
    # Script length and content
    coinbase_msg = b"Vertocoin - The future of fast transactions [vertomax.com]"
    script_sig = struct.pack('<I', 486604799)  # Block height (0) + extra nonce
    script_sig += struct.pack('B', 4)  # Push 4 bytes
    script_sig += struct.pack('B', len(coinbase_msg))  # Push message
    script_sig += coinbase_msg
    
    tx += struct.pack('B', len(script_sig))  # Script length
    tx += script_sig
    tx += struct.pack('<I', 0xFFFFFFFF)  # Sequence
    
    # Output count
    tx += b'\x01'
    
    # Output value (2,000,000,000 VTO = 2,000,000,000 * 100,000,000 satoshis)
    value = 2000000000 * 100000000
    tx += struct.pack('<Q', value)
    
    # Output script (P2PK with the genesis key)
    pubkey = bytes.fromhex("04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f")
    script_pubkey = struct.pack('B', len(pubkey)) + pubkey + b'\xAC'  # OP_CHECKSIG
    
    tx += struct.pack('B', len(script_pubkey))
    tx += script_pubkey
    
    # Lock time
    tx += struct.pack('<I', 0)
    
    return tx

if __name__ == "__main__":
    # Create genesis transaction
    genesis_tx = create_genesis_transaction()
    merkle_root = hash256(genesis_tx)
    
    print("Genesis transaction hash:", hash256(genesis_tx)[::-1].hex())
    print("Merkle root:", merkle_root.hex())
    
    # Mine genesis block
    timestamp = 1719792000  # July 1st, 2025 00:00:00 UTC
    bits = 0x207fffff  # Lower difficulty for easier mining
    
    nonce, block_hash = mine_genesis_block(timestamp, merkle_root, bits)
    
    if nonce is not None:
        print("\n=== GENESIS BLOCK FOUND ===")
        print(f"Timestamp: {timestamp}")
        print(f"Nonce: {nonce}")
        print(f"Block hash: {block_hash.hex()}")
        print(f"Merkle root: {merkle_root.hex()}")
        print("\nUpdate your chainparams.cpp with these values:")
        print(f'genesis = CreateGenesisBlock({timestamp}, {nonce}, 0x{bits:08x}, 1, 2000000000LL * COIN);')
        print(f'assert(consensus.hashGenesisBlock == uint256{{"{block_hash.hex()}"}});')
        print(f'assert(genesis.hashMerkleRoot == uint256{{"{merkle_root.hex()}"}});')
