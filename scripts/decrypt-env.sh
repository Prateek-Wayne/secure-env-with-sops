#!/bin/bash
set -e

# Get the directory of the script
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
# The project root is the parent directory of the script's directory
PROJECT_ROOT="$SCRIPT_DIR/.."

# Define file paths relative to the project root
ENC_FILE="$PROJECT_ROOT/enc.env"
DEC_FILE="$PROJECT_ROOT/.env"

if [ ! -f "$ENC_FILE" ]; then
    echo "Error: $ENC_FILE file not found!"
    echo "Please make sure the encrypted file exists in the project root."
    exit 1
fi

echo "Decrypting $ENC_FILE to $DEC_FILE..."
sops --decrypt --input-type dotenv --output-type dotenv "$ENC_FILE" > "$DEC_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Successfully decrypted to $DEC_FILE"
    echo "Your environment variables are now available."
    echo "Note: .env is git-ignored and won't be committed."
else
    echo "❌ Decryption failed!"
    echo "Make sure you have the correct GPG key and permissions to decrypt this file."
    exit 1
fi