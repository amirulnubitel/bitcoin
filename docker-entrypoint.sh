#!/bin/bash
set -e

# Ensure data directory exists
mkdir -p /home/vertocoin/.vertocoin/wallets

# Function to safely change ownership if writable
safe_chown() {
    local target="$1"
    local owner="$2"
    local perm="$3"
    
    if [ -e "$target" ] && [ -w "$target" ]; then
        chown "$owner" "$target" 2>/dev/null || true
        if [ -n "$perm" ]; then
            chmod "$perm" "$target" 2>/dev/null || true
        fi
    fi
}

# Function to safely change ownership recursively if writable
safe_chown_recursive() {
    local target="$1"
    local owner="$2"
    local perm="$3"
    
    if [ -d "$target" ] && [ -w "$target" ]; then
        find "$target" -writable -exec chown "$owner" {} + 2>/dev/null || true
        if [ -n "$perm" ]; then
            find "$target" -writable -type f -exec chmod "$perm" {} + 2>/dev/null || true
            find "$target" -writable -type d -exec chmod 755 {} + 2>/dev/null || true
        fi
    fi
}

# Change ownership of the main data directory if writable
safe_chown /home/vertocoin/.vertocoin vertocoin:vertocoin 755

# Change ownership of wallets directory recursively if writable
safe_chown_recursive /home/vertocoin/.vertocoin/wallets vertocoin:vertocoin 644

# Try to change ownership of config file only if it's writable
safe_chown /home/vertocoin/.vertocoin/vertocoin.conf vertocoin:vertocoin 644

# Handle any other files in the data directory (except config file)
find /home/vertocoin/.vertocoin -type f -writable -not -name "vertocoin.conf" -exec chown vertocoin:vertocoin {} + 2>/dev/null || true
find /home/vertocoin/.vertocoin -type d -writable -not -path "/home/vertocoin/.vertocoin" -exec chown vertocoin:vertocoin {} + 2>/dev/null || true

# If running as root, drop privileges to vertocoin user
if [ "$(id -u)" = "0" ]; then
    exec gosu vertocoin "$0" "$@"
fi

# Default to running vertocoind if no command specified
if [ "$#" -eq 0 ]; then
    exec vertocoind -conf=/home/vertocoin/.vertocoin/vertocoin.conf -datadir=/home/vertocoin/.vertocoin
else
    exec "$@"
fi
