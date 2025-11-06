# Quick Deployment Guide - Step by Step

## Step 1: Install Foundry (One-Time Setup)

### Option A: Using Git Bash (Easiest)

1. **Open Git Bash** (search "Git Bash" in Windows Start menu)

2. **Navigate to project**:
   ```bash
   cd /c/Users/MSI/Desktop/walletconnect/ticketing-platform/smartcontract
   ```

3. **Install Foundry**:
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   source $HOME/.bashrc
   foundryup
   ```

4. **Verify installation**:
   ```bash
   forge --version
   ```

### Option B: If Git Bash doesn't work, use WSL

1. Open PowerShell as Administrator
2. Run: `wsl --install`
3. Restart computer
4. Open WSL and follow Git Bash steps above

## Step 2: Get Testnet Tokens

1. Visit: https://faucet.celo.org/alfajores
2. Connect your wallet (MetaMask recommended)
3. Request testnet CELO tokens
4. Wait a few moments for tokens to arrive

## Step 3: Create .env File

In Git Bash (or your terminal), run:

```bash
cd /c/Users/MSI/Desktop/walletconnect/ticketing-platform/smartcontract

cat > .env << 'EOF'
PRIVATE_KEY=your_private_key_here
CELO_TESTNET_RPC_URL=https://alfajores-forno.celo-testnet.org
CELOSCAN_API_KEY=
EOF
```

Then edit `.env` and replace `your_private_key_here` with your actual private key (without 0x prefix).

**To get your private key from MetaMask:**
1. Open MetaMask
2. Click three dots → Account details → Export Private Key
3. Copy the key (without 0x prefix)

## Step 4: Deploy

In Git Bash, run:

```bash
source .env
forge script script/TicketingPlatform.s.sol:TicketingPlatformScript \
  --rpc-url $CELO_TESTNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

## What Happens During Deployment

1. **Builds** your contracts
2. **Deploys** TicketNFT contract
3. **Deploys** TicketingPlatform contract
4. **Transfers** TicketNFT ownership to platform
5. **Shows** contract addresses

## After Deployment

You'll see output like:
```
TicketNFT deployed at: 0x...
TicketingPlatform deployed at: 0x...
```

**Save these addresses!** You'll need them for your frontend.

## Troubleshooting

### "forge: command not found"
- Make sure Foundry is installed
- Restart Git Bash after installation
- Try: `source $HOME/.bashrc`

### "Insufficient funds"
- Get testnet tokens from: https://faucet.celo.org/alfajores

### "Invalid private key"
- Make sure your private key doesn't have `0x` prefix
- Check for extra spaces

### Still having issues?
- Check `DEPLOY_POWERSHELL.md` for PowerShell alternatives
- Or use the manual commands below

