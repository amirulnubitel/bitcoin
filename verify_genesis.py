#!/usr/bin/env python3

import hashlib
import struct
import time

def hash256(data):
    """Double SHA256 hash"""
    return hashlib.sha256(hashlib.sha256(data).digest()).digest()

def create_genesis_transaction():
    """Create the genesis transaction based on chainparams.cpp"""
    
    # Genesis transaction parameters from chainparams.cpp
    timestamp_msg = "Vertocoin - The future of fast transactions [vertomax.com]"
    pubkey_hex = "04678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5f"
    genesis_reward = 2000000000 * 100000000  # 2 billion VTO in satoshis
    
    # Create coinbase input scriptSig
    # Format: <height> <extra_nonce> <timestamp_msg>
    height = 486604799  # From chainparams.cpp
    extra_nonce = 4     # From chainparams.cpp
    
    # Build scriptSig
    scriptsig = b""
    scriptsig += struct.pack("<I", height)
    scriptsig += struct.pack("<B", extra_nonce)
    scriptsig += struct.pack("<B", len(timestamp_msg))
    scriptsig += timestamp_msg.encode('utf-8')
    
    # Create output scriptPubKey (P2PK)
    pubkey_bytes = bytes.fromhex(pubkey_hex)
    scriptpubkey = struct.pack("<B", len(pubkey_bytes)) + pubkey_bytes + b"\xac"  # OP_CHECKSIG
    
    # Build transaction
    tx = b""
    tx += struct.pack("<I", 1)  # version
    tx += struct.pack("<B", 1)  # input count
    
    # Input (coinbase)
    tx += b"\x00" * 32  # previous output hash (null)
    tx += struct.pack("<I", 0xffffffff)  # previous output index
    tx += struct.pack("<B", len(scriptsig))  # script length
    tx += scriptsig
    tx += struct.pack("<I", 0xffffffff)  # sequence
    
    # Output count
    tx += struct.pack("<B", 1)
    
    # Output
    tx += struct.pack("<Q", genesis_reward)  # value
    tx += struct.pack("<B", len(scriptpubkey))  # script length
    tx += scriptpubkey
    
    # Locktime
    tx += struct.pack("<I", 0)
    
    return tx

def calculate_merkle_root(tx_hashes):
    """Calculate merkle root from transaction hashes"""
    if len(tx_hashes) == 0:
        return b"\x00" * 32
    
    if len(tx_hashes) == 1:
        return tx_hashes[0]
    
    # For genesis block with single transaction, merkle root is just the transaction hash
    return tx_hashes[0]

def mine_genesis_block(target_bits=0x207fffff, start_nonce=0):
    """Mine the genesis block by finding a valid nonce"""
    
    # Genesis block parameters
    version = 1
    prev_hash = b"\x00" * 32
    timestamp = 1719792000
    
    # Create genesis transaction
    genesis_tx = create_genesis_transaction()
    tx_hash = hash256(genesis_tx)
    merkle_root = calculate_merkle_root([tx_hash])
    
    print("Genesis Block Generation")
    print("=" * 50)
    print(f"Timestamp: {timestamp}")
    print(f"Target bits: 0x{target_bits:08x}")
    print(f"Genesis transaction hash: {tx_hash.hex()}")
    print(f"Merkle root: {merkle_root.hex()}")
    print(f"Previous hash: {prev_hash.hex()}")
    print(f"Starting nonce: {start_nonce}")
    print("\nMining...")
    
    # Calculate target from bits
    target = target_bits & 0x00ffffff
    exponent = (target_bits >> 24) & 0xff
    target = target * (2 ** (8 * (exponent - 3)))
    
    nonce = start_nonce
    start_time = time.time()
    
    while True:
        # Create block header
        header = struct.pack(
            '<I32s32sIII',
            version,
            prev_hash,
            merkle_root,
            timestamp,
            target_bits,
            nonce
        )
        
        # Hash the header
        hash_result = hash256(header)
        hash_int = int.from_bytes(hash_result, 'big')
        
        # Check if we found a valid block
        if hash_int < target:
            elapsed = time.time() - start_time
            hash_hex = hash_result[::-1].hex()  # Reverse for display
            
            print(f"\n🎉 Genesis block found!")
            print(f"Nonce: {nonce}")
            print(f"Hash: {hash_hex}")
            print(f"Time elapsed: {elapsed:.2f} seconds")
            print(f"Hash rate: {nonce/elapsed:.0f} H/s")
            
            return {
                'version': version,
                'prev_hash': prev_hash.hex(),
                'merkle_root': merkle_root.hex(),
                'timestamp': timestamp,
                'target_bits': target_bits,
                'nonce': nonce,
                'hash': hash_hex,
                'transaction': genesis_tx.hex()
            }
        
        nonce += 1
        
        # Progress update
        if nonce % 100000 == 0:
            elapsed = time.time() - start_time
            if elapsed > 0:
                print(f"Nonce: {nonce:,} | Hash rate: {nonce/elapsed:.0f} H/s")

def verify_genesis_block(block_params):
    """Verify the genesis block parameters"""
    
    version = block_params['version']
    prev_hash = bytes.fromhex(block_params['prev_hash'])
    merkle_root = bytes.fromhex(block_params['merkle_root'])
    timestamp = block_params['timestamp']
    target_bits = block_params['target_bits']
    nonce = block_params['nonce']
    
    # Create block header
    header = struct.pack(
        '<I32s32sIII',
        version,
        prev_hash,
        merkle_root,
        timestamp,
        target_bits,
        nonce
    )
    
    # Hash the header
    hash_result = hash256(header)
    hash_hex = hash_result[::-1].hex()
    
    print("\nGenesis Block Verification")
    print("=" * 50)
    print(f"Version: {version}")
    print(f"Previous hash: {block_params['prev_hash']}")
    print(f"Merkle root: {block_params['merkle_root']}")
    print(f"Timestamp: {timestamp}")
    print(f"Target bits: 0x{target_bits:08x}")
    print(f"Nonce: {nonce}")
    print(f"Block hash: {hash_hex}")
    
    # Check if hash meets target
    target = target_bits & 0x00ffffff
    exponent = (target_bits >> 24) & 0xff
    target = target * (2 ** (8 * (exponent - 3)))
    hash_int = int.from_bytes(hash_result, 'big')
    
    print(f"Hash meets target: {hash_int < target}")
    
    return hash_hex == block_params['hash']

if __name__ == "__main__":
    # Mine genesis block
    genesis_block = mine_genesis_block()
    
    # Verify the result
    verify_genesis_block(genesis_block)
    
    # Print C++ format for chainparams.cpp
    print("\n" + "=" * 50)
    print("UPDATE FOR CHAINPARAMS.CPP:")
    print("=" * 50)
    print(f"genesis = CreateGenesisBlock({genesis_block['timestamp']}, {genesis_block['nonce']}, 0x{genesis_block['target_bits']:08x}, {genesis_block['version']}, 2000000000LL * COIN);")
    print(f"consensus.hashGenesisBlock = uint256{{\"0x{genesis_block['hash']}\"}};\n")
    print(f"assert(consensus.hashGenesisBlock == uint256{{\"0x{genesis_block['hash']}\"}});")
    print(f"assert(genesis.hashMerkleRoot == uint256{{\"0x{genesis_block['merkle_root']}\"}});")
    print("\nGenesis transaction hex:")
    print(genesis_block['transaction'])
