#!/usr/bin/env python3

import hashlib
import struct

def hash256(data):
    """Double SHA256 hash"""
    return hashlib.sha256(hashlib.sha256(data).digest()).digest()

def calculate_genesis_hash():
    """Calculate the actual hash for our genesis block parameters"""
    
    # Parameters from chainparams.cpp
    version = 1
    prev_hash = "0000000000000000000000000000000000000000000000000000000000000000"
    merkle_root = "e9cdd17d0935491ae1bfa045800e17381f987f96991d40febf7b5cb7e293fba2"
    timestamp = 1719792000
    target_bits = 0x1f00ffff
    nonce = 118636
    
    print(f"Genesis block parameters:")
    print(f"Version: {version}")
    print(f"Previous hash: {prev_hash}")
    print(f"Merkle root: {merkle_root}")
    print(f"Timestamp: {timestamp}")
    print(f"Target bits: 0x{target_bits:08x}")
    print(f"Nonce: {nonce}")
    
    # Convert strings to bytes
    prev_hash_bytes = bytes.fromhex(prev_hash)
    merkle_root_bytes = bytes.fromhex(merkle_root)
    
    # Create block header (80 bytes)
    header = struct.pack(
        '<I32s32sIII',  # version(4) + prev_hash(32) + merkle_root(32) + timestamp(4) + bits(4) + nonce(4)
        version,
        prev_hash_bytes,
        merkle_root_bytes,
        timestamp,
        target_bits,
        nonce
    )
    
    # Hash the header
    hash_result = hash256(header)
    
    # Convert to hex string (big-endian display)
    hash_hex = hash_result[::-1].hex()
    
    print(f"\nCalculated genesis hash: {hash_hex}")
    print(f"Expected hash: 000092d308e918a0036a633b2c931ad9112b0c83f341b0cbc3fecbcddbbd503e")
    print(f"Match: {hash_hex == '000092d308e918a0036a633b2c931ad9112b0c83f341b0cbc3fecbcddbbd503e'}")
    
    return hash_hex

if __name__ == "__main__":
    calculate_genesis_hash()
