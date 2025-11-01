# PowerShell script to decrypt YAML file using SOPS
# Windows equivalent of decrypt-yaml.sh

# Enable strict error handling
$ErrorActionPreference = "Stop"

# Get the script directory and project root
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$projectRoot = Split-Path -Parent $scriptDir

# Change to project root directory to ensure relative paths work
Push-Location $projectRoot

try {
    # Check if the encrypted YAML file exists
    if (-not (Test-Path "secrets.dev.enc.yaml")) {
        Write-Host "Error: secrets.dev.enc.yaml file not found!" -ForegroundColor Red
        Write-Host "Please make sure the encrypted YAML file exists."
        exit 1
    }

    Write-Host "Decrypting secrets.dev.enc.yaml to secrets.dev.yaml..."

    # Run sops decrypt command and redirect output to file
    $decryptOutput = sops --decrypt secrets.dev.enc.yaml
    $decryptOutput | Out-File -FilePath "secrets.dev.yaml" -Encoding UTF8
    
    # Check if the operation was successful
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Successfully decrypted secrets.dev.enc.yaml to secrets.dev.yaml" -ForegroundColor Green
        Write-Host "Your decrypted YAML file is now available as secrets.dev.yaml"
        Write-Host "Note: secrets.dev.yaml should be git-ignored and won't be committed"
        Write-Host ""
        Write-Host "Decrypted content preview:"
        Write-Host "=========================="
        
        # Display first 10 lines of the decrypted file (equivalent to head -10)
        Get-Content "secrets.dev.yaml" | Select-Object -First 10
    }
    else {
        throw "SOPS command failed with exit code $LASTEXITCODE"
    }
}
catch {
    Write-Host "❌ Decryption failed!" -ForegroundColor Red
    Write-Host "Make sure you have the correct PGP key to decrypt this file"
    Write-Host "Required PGP keys:"
    Write-Host "- 196e2fb0add1fa0ea00e377eb92cc7cd1b5275ca"
    Write-Host "- d7d1ff182af9f304af01db8f15ef228052ff6d2f"
    Write-Host "Error details: $($_.Exception.Message)" -ForegroundColor Yellow
    exit 1
}
finally {
    # Return to original directory
    Pop-Location
}