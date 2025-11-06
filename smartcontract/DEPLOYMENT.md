# Deployment Guide for Celo Mainnet

This guide will help you deploy the Ticketing Platform smart contracts to Celo Mainnet.

## Prerequisites

1. **Install Foundry** (if not already installed):
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Fund your wallet with CELO**:
   - You need CELO tokens to pay for gas fees
   - Get CELO from an exchange or faucet
   - Ensure your wallet has sufficient balance (recommended: 0.5-1 CELO minimum)

3. **Get a Celo RPC URL**:
   - Option 1: Use public RPC (free but rate-limited):
     - `https://forno.celo.org`
   - Option 2: Get a dedicated RPC from providers:
     - Infura: https://infura.io
     - Alchemy: https://alchemy.com
     - QuickNode: https://quicknode.com

## Setup

1. **Create a `.env` file** in the `smartcontract` directory:
   ```bash
   cd smartcontract
   touch .env
   ```

2. **Add your environment variables** to `.env`:
   ```env
   # Your private key (without 0x prefix)
   PRIVATE_KEY=your_private_key_here
   
   # Celo Mainnet RPC URL
   CELO_RPC_URL=https://forno.celo.org
   # OR use a dedicated RPC from Infura/Alchemy:
   # CELO_RPC_URL=https://celo-mainnet.infura.io/v3/YOUR_INFURA_PROJECT_ID
   ```

3. **Verify your configuration**:
   ```bash
   # Check your deployer address
   forge script script/TicketingPlatform.s.sol:TicketingPlatformScript --rpc-url $CELO_RPC_URL
   ```

## Deployment Steps

### Step 1: Simulate the Deployment (Dry Run)

First, simulate the deployment to verify everything works:

```bash
forge script script/TicketingPlatform.s.sol:TicketingPlatformScript \
  --rpc-url $CELO_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

### Step 2: Deploy to Celo Mainnet

Once you're ready, deploy the contracts:

```bash
forge script script/TicketingPlatform.s.sol:TicketingPlatformScript \
  --rpc-url $CELO_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $CELOSCAN_API_KEY
```

**Note**: Replace `$CELOSCAN_API_KEY` with your Celoscan API key if you want to verify contracts. Get your API key from: https://celoscan.io/myapikey

### Step 3: Verify Deployment

After deployment, you'll see output like:
```
TicketNFT deployed at: 0x...
TicketingPlatform deployed at: 0x...
```

Save these addresses - you'll need them for your frontend integration.

### Alternative: Deploy without Verification

If you don't want to verify contracts immediately:

```bash
forge script script/TicketingPlatform.s.sol:TicketingPlatformScript \
  --rpc-url $CELO_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast
```

## Post-Deployment

1. **Verify contracts on Celoscan** (if you used `--verify`):
   - Visit https://celoscan.io
   - Search for your contract addresses
   - Verify they're deployed correctly

2. **Update your frontend**:
   - Update the contract addresses in your frontend configuration
   - Update the network to Celo Mainnet (Chain ID: 42220)

3. **Test the contracts**:
   - Create a test event
   - Purchase a test ticket
   - Verify everything works as expected

## Configuration

### Platform Fee
- Default: 2.5% (250 basis points)
- Can be changed by the owner using `setPlatformFeePercentage()`

### Max Resale Price
- Default: 150% of original price (15000 basis points)
- Can be changed by the owner using `setMaxResalePricePercentage()`

## Security Considerations

⚠️ **IMPORTANT SECURITY NOTES**:

1. **Never commit your `.env` file** to version control
2. **Never share your private key** publicly
3. **Use a dedicated deployment wallet** with only the funds needed for deployment
4. **Verify all contracts** on Celoscan after deployment
5. **Test on Celo Testnet first** (Alfajores) before mainnet deployment

## Celo Mainnet Details

- **Chain ID**: 42220
- **Network Name**: Celo Mainnet
- **Currency**: CELO
- **Block Explorer**: https://celoscan.io
- **RPC Endpoints**:
  - Public: `https://forno.celo.org`
  - Infura: `https://celo-mainnet.infura.io/v3/YOUR_PROJECT_ID`
  - Alchemy: `https://eth-celo.g.alchemy.com/v2/YOUR_API_KEY`

## Troubleshooting

### Error: "Insufficient funds for gas"
- Ensure your wallet has enough CELO tokens
- Check your balance: `cast balance YOUR_ADDRESS --rpc-url $CELO_RPC_URL`

### Error: "Contract verification failed"
- Make sure you have a valid Celoscan API key
- Check that the contract source code matches
- Try verifying manually on Celoscan

### Error: "Nonce too high"
- Your transactions may be out of order
- Wait for pending transactions to complete
- Or manually set the nonce

## Support

For issues or questions:
- Check the contract documentation in the code
- Review the test files for usage examples
- Visit Celo documentation: https://docs.celo.org

