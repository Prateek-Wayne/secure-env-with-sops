#!/bin/bash
set -e

if [ ! -f "secrets.dev.enc.yaml" ]; then
    echo "Error: secrets.dev.enc.yaml file not found!"
    echo "Please make sure the encrypted YAML file exists."
    exit 1
fi

echo "Decrypting secrets.dev.enc.yaml to secrets.dev.yaml..."
sops --decrypt secrets.dev.enc.yaml > secrets.dev.yaml

if [ $? -eq 0 ]; then
    echo "✅ Successfully decrypted secrets.dev.enc.yaml to secrets.dev.yaml"
    echo "Your decrypted YAML file is now available as secrets.dev.yaml"
    echo "Note: secrets.dev.yaml should be git-ignored and won't be committed"
    echo ""
    echo "Decrypted content preview:"
    echo "=========================="
    head -10 secrets.dev.yaml
else
    echo "❌ Decryption failed!"
    echo "Make sure you have the correct PGP key to decrypt this file"
    echo "Required PGP keys:"
    echo "- 196e2fb0add1fa0ea00e377eb92cc7cd1b5275ca"
    echo "- d7d1ff182af9f304af01db8f15ef228052ff6d2f"
    exit 1
fi