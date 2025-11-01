# PowerShell script to decrypt .env file using SOPS
# Windows equivalent of decrypt-env.sh

# Enable strict error handling
$ErrorActionPreference = "Stop"

# Get the script directory and project root
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDir

# Change to project root directory to ensure relative paths work
Push-Location $projectRoot

try {
    # Check if the encrypted env file exists
    if (-not (Test-Path "enc.env")) {
        Write-Host "Error: enc.env file not found!" -ForegroundColor Red
        Write-Host "Please make sure the encrypted file exists."
        exit 1
    }

    Write-Host "Decrypting enc.env to .env..."

    # Run sops decrypt command with dotenv input/output types
    $decryptOutput = sops --decrypt --input-type dotenv --output-type dotenv enc.env
    $decryptOutput | Out-File -FilePath ".env" -Encoding UTF8
    
    # Check if the operation was successful
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Successfully decrypted enc.env to .env" -ForegroundColor Green
        Write-Host "Your environment variables are now available in .env"
        Write-Host "Note: .env is git-ignored and won't be committed"
    }
    else {
        throw "SOPS command failed with exit code $LASTEXITCODE"
    }
}
catch {
    Write-Host "❌ Decryption failed!" -ForegroundColor Red
    Write-Host "Make sure you have the correct PGP key to decrypt this file"
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Yellow
    exit 1
}
finally {
    # Return to original directory
    Pop-Location
}