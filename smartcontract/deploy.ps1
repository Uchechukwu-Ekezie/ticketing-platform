# PowerShell Deployment Script for Celo Testnet
# Usage: .\deploy.ps1

Write-Host "=== Celo Testnet Deployment Script ===" -ForegroundColor Cyan

# Check if .env file exists
if (-not (Test-Path .env)) {
    Write-Host "Error: .env file not found!" -ForegroundColor Red
    Write-Host "Please create a .env file with:" -ForegroundColor Yellow
    Write-Host "PRIVATE_KEY=your_private_key_here" -ForegroundColor Yellow
    Write-Host "CELO_TESTNET_RPC_URL=https://alfajores-forno.celo-testnet.org" -ForegroundColor Yellow
    Write-Host "CELOSCAN_API_KEY=your_celoscan_api_key_here" -ForegroundColor Yellow
    exit 1
}

# Load .env file
Write-Host "Loading environment variables..." -ForegroundColor Green
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^#][^=]+)=(.*)$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        [Environment]::SetEnvironmentVariable($name, $value, "Process")
        Write-Host "  Loaded: $name" -ForegroundColor Gray
    }
}

# Check if required variables are set
if (-not $env:PRIVATE_KEY) {
    Write-Host "Error: PRIVATE_KEY not found in .env file!" -ForegroundColor Red
    exit 1
}

if (-not $env:CELO_TESTNET_RPC_URL) {
    $env:CELO_TESTNET_RPC_URL = "https://alfajores-forno.celo-testnet.org"
    Write-Host "Using default Celo testnet RPC: $env:CELO_TESTNET_RPC_URL" -ForegroundColor Yellow
}

# Check if forge is available
try {
    $forgeVersion = forge --version 2>&1
    Write-Host "Foundry version: $forgeVersion" -ForegroundColor Green
} catch {
    Write-Host "Error: forge command not found!" -ForegroundColor Red
    Write-Host "Please install Foundry first:" -ForegroundColor Yellow
    Write-Host "  curl -L https://foundry.paradigm.xyz | bash" -ForegroundColor Yellow
    Write-Host "  foundryup" -ForegroundColor Yellow
    Write-Host "Or use Git Bash instead of PowerShell" -ForegroundColor Yellow
    exit 1
}

# Deploy
Write-Host "`nDeploying contracts to Celo Alfajores Testnet..." -ForegroundColor Cyan
Write-Host "RPC URL: $env:CELO_TESTNET_RPC_URL" -ForegroundColor Gray
Write-Host "Deployer: $((cast wallet address $env:PRIVATE_KEY))" -ForegroundColor Gray

$deployCommand = "forge script script/TicketingPlatform.s.sol:TicketingPlatformScript --rpc-url $env:CELO_TESTNET_RPC_URL --private-key $env:PRIVATE_KEY --broadcast"

if ($env:CELOSCAN_API_KEY) {
    $deployCommand += " --verify --etherscan-api-key $env:CELOSCAN_API_KEY"
}

Write-Host "`nRunning deployment command..." -ForegroundColor Green
Invoke-Expression $deployCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=== Deployment Complete! ===" -ForegroundColor Green
    Write-Host "Check the output above for contract addresses." -ForegroundColor Yellow
} else {
    Write-Host "`n=== Deployment Failed ===" -ForegroundColor Red
    Write-Host "Exit code: $LASTEXITCODE" -ForegroundColor Yellow
}

