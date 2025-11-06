# Deployment Guide for PowerShell (Windows)

## Step 1: Install Foundry

If you don't have Foundry installed, follow these steps:

### Option A: Using foundryup (Recommended)

1. **Install Rust** (if not already installed):
   - Visit https://rustup.rs/
   - Download and run the installer
   - Follow the installation instructions

2. **Install Foundry**:
   Open PowerShell and run:
   ```powershell
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

   If the above doesn't work, try:
   ```powershell
   irm https://github.com/foundry-rs/foundry/releases/latest/download/foundry_nightly_windows_amd64.tar.gz -OutFile foundry.tar.gz
   # Then extract and add to PATH
   ```

### Option B: Using Git Bash (Easier on Windows)

1. Install Git for Windows: https://git-scm.com/download/win
2. Open Git Bash (not PowerShell)
3. Run:
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

## Step 2: Verify Installation

After installation, verify Foundry is installed:

```powershell
forge --version
cast --version
anvil --version
```

If these commands don't work, you may need to:
1. Restart your terminal/PowerShell
2. Add Foundry to your PATH manually
3. Use Git Bash instead

## Step 3: Get Testnet Tokens

Visit the Celo Alfajores faucet:
```
https://faucet.celo.org/alfajores
```

Connect your wallet and request testnet tokens.

## Step 4: Create .env File

Create a `.env` file in the `smartcontract` directory:

**PowerShell:**
```powershell
cd smartcontract
@"
PRIVATE_KEY=your_private_key_here
CELO_TESTNET_RPC_URL=https://alfajores-forno.celo-testnet.org
CELOSCAN_API_KEY=your_celoscan_api_key_here
"@ | Out-File -FilePath .env -Encoding utf8
```

**Or manually create** `.env` file with:
```
PRIVATE_KEY=your_private_key_here
CELO_TESTNET_RPC_URL=https://alfajores-forno.celo-testnet.org
CELOSCAN_API_KEY=your_celoscan_api_key_here
```

## Step 5: Deploy (PowerShell Commands)

### Option 1: Single Line Command (PowerShell)

```powershell
$env:PRIVATE_KEY="your_private_key_here"; $env:CELO_TESTNET_RPC_URL="https://alfajores-forno.celo-testnet.org"; forge script script/TicketingPlatform.s.sol:TicketingPlatformScript --rpc-url $env:CELO_TESTNET_RPC_URL --private-key $env:PRIVATE_KEY --broadcast --verify
```

### Option 2: Load .env and Deploy (PowerShell)

Create a script `deploy.ps1`:
```powershell
# deploy.ps1
$envFile = Get-Content .env -Raw
$envFile -split "`n" | ForEach-Object {
    if ($_ -match '^([^#][^=]+)=(.*)$') {
        $name = $matches[1].Trim()
        $value = $matches[2].Trim()
        [Environment]::SetEnvironmentVariable($name, $value, "Process")
    }
}

forge script script/TicketingPlatform.s.sol:TicketingPlatformScript `
    --rpc-url $env:CELO_TESTNET_RPC_URL `
    --private-key $env:PRIVATE_KEY `
    --broadcast `
    --verify `
    --etherscan-api-key $env:CELOSCAN_API_KEY
```

Then run:
```powershell
.\deploy.ps1
```

### Option 3: Use Git Bash (Recommended for Windows)

If you have Git Bash installed, use it instead:

```bash
cd smartcontract
source .env  # or manually set variables
forge script script/TicketingPlatform.s.sol:TicketingPlatformScript \
  --rpc-url $CELO_TESTNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $CELOSCAN_API_KEY
```

## Step 6: Manual Deployment (If Scripts Don't Work)

If you're having issues with environment variables, deploy directly:

```powershell
forge script script/TicketingPlatform.s.sol:TicketingPlatformScript --rpc-url https://alfajores-forno.celo-testnet.org --private-key YOUR_PRIVATE_KEY_HERE --broadcast --verify
```

Replace `YOUR_PRIVATE_KEY_HERE` with your actual private key (without 0x prefix).

## Troubleshooting

### "forge: command not found"
- Foundry is not installed or not in PATH
- **Solution**: Install Foundry using the steps above
- Or use Git Bash which often handles this better

### "Cannot find module"
- Make sure you're in the `smartcontract` directory
- Run `forge install` if needed

### PowerShell Line Continuation
- PowerShell uses backticks `` ` `` for line continuation (not `\`)
- Or use single-line commands
- Or use Git Bash instead

### Environment Variables Not Loading
- PowerShell handles `.env` files differently than bash
- Use the `deploy.ps1` script above
- Or manually set variables:
  ```powershell
  $env:PRIVATE_KEY="your_key"
  $env:CELO_TESTNET_RPC_URL="https://alfajores-forno.celo-testnet.org"
  ```

## Recommended: Use Git Bash

For Foundry/Forge, Git Bash is often easier on Windows:

1. Install Git for Windows
2. Open Git Bash
3. Use the bash commands from `DEPLOY_TESTNET.md`

## Quick Reference

**Celo Alfajores Testnet:**
- Chain ID: 44787
- RPC: https://alfajores-forno.celo-testnet.org
- Explorer: https://alfajores.celoscan.io
- Faucet: https://faucet.celo.org/alfajores

