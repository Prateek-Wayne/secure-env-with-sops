#!/bin/bash
set -e

if [ ! -f "enc.env" ]; then
    echo "Error: enc.env file not found!"
    echo "Please make sure the encrypted file exists."
    exit 1
fi

echo "Decrypting enc.env to .env..."
sops --decrypt --input-type dotenv --output-type dotenv enc.env > .env

if [ $? -eq 0 ]; then
    echo "✅ Successfully decrypted enc.env to .env"
    echo "Your environment variables are now available in .env"
    echo "Note: .env is git-ignored and won't be committed"
else
    echo "❌ Decryption failed!"
    echo "Make sure you have the correct PGP key to decrypt this file"
    exit 1
fi