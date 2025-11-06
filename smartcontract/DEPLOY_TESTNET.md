# Deployment Guide for Celo Alfajores Testnet

This guide will help you deploy the Ticketing Platform smart contracts to Celo Alfajores Testnet.

## Prerequisites

1. **Install Foundry** (if not already installed):
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Get testnet CELO tokens**:
   - Visit the Celo Alfajores faucet: https://faucet.celo.org/alfajores
   - Connect your wallet and request testnet tokens
   - You'll need CELO for gas fees (they're free on testnet!)

3. **Get a Celo Testnet RPC URL**:
   - Public RPC (free): `https://alfajores-forno.celo-testnet.org`
   - Or use a dedicated RPC from providers (Infura, Alchemy, QuickNode)

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
   
   # Celo Alfajores Testnet RPC URL
   CELO_TESTNET_RPC_URL=https://alfajores-forno.celo-testnet.org
   
   # Optional: For contract verification
   CELOSCAN_API_KEY=your_celoscan_api_key_here
   ```

## Deployment Steps

### Step 1: Get Testnet Tokens

1. Visit https://faucet.celo.org/alfajores
2. Connect your wallet (MetaMask recommended)
3. Request testnet CELO tokens
4. Wait a few moments for the tokens to arrive

### Step 2: Verify Your Balance

Check your testnet balance:
```bash
source .env
cast balance $(cast wallet address $PRIVATE_KEY) --rpc-url $CELO_TESTNET_RPC_URL
```

### Step 3: Simulate the Deployment (Dry Run)

First, simulate the deployment to verify everything works:

```bash
source .env
forge script script/TicketingPlatform.s.sol:TicketingPlatformScript \
  --rpc-url $CELO_TESTNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

### Step 4: Deploy to Celo Alfajores Testnet

Deploy the contracts:

```bash
source .env
forge script script/TicketingPlatform.s.sol:TicketingPlatformScript \
  --rpc-url $CELO_TESTNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $CELOSCAN_API_KEY
```

**Note**: Contract verification is optional but recommended. Get your Celoscan API key from: https://alfajores.celoscan.io/myapikey

### Step 5: Verify Deployment

After deployment, you'll see output like:
```
TicketNFT deployed at: 0x...
TicketingPlatform deployed at: 0x...
```

Save these addresses - you'll need them for your frontend integration.

## Quick Deploy Command

For quick deployment, use this single command:

```bash
forge script script/TicketingPlatform.s.sol:TicketingPlatformScript \
  --rpc-url https://alfajores-forno.celo-testnet.org \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify
```

## Post-Deployment

1. **Verify contracts on Celoscan Testnet**:
   - Visit https://alfajores.celoscan.io
   - Search for your contract addresses
   - Verify they're deployed correctly

2. **Update your frontend**:
   - Update the contract addresses in your frontend configuration
   - Update the network to Celo Alfajores (Chain ID: 44787)

3. **Test the contracts**:
   - Create a test event
   - Purchase test tickets
   - Test resale functionality
   - Verify everything works as expected

## Celo Alfajores Testnet Details

- **Chain ID**: 44787
- **Network Name**: Celo Alfajores
- **Currency**: CELO (testnet tokens)
- **Block Explorer**: https://alfajores.celoscan.io
- **Faucet**: https://faucet.celo.org/alfajores
- **RPC Endpoints**:
  - Public: `https://alfajores-forno.celo-testnet.org`
  - Infura: `https://celo-alfajores.infura.io/v3/YOUR_PROJECT_ID`
  - Alchemy: `https://eth-alfajores.g.alchemy.com/v2/YOUR_API_KEY`

## Testing Your Contracts

After deployment, test the following:

1. **Create an event**:
   ```solidity
   platform.createEvent(
     "Test Event",
     "A test event",
     block.timestamp + 7 days,
     "Test Location",
     0.01 ether,
     100,
     0
   );
   ```

2. **Purchase a ticket**:
   ```solidity
   platform.purchaseTicket{value: 0.01 ether}(eventId);
   ```

3. **List for resale**:
   ```solidity
   platform.listTicketForResale(tokenId, 0.015 ether);
   ```

4. **Purchase from resale**:
   ```solidity
   platform.purchaseResaleTicket{value: 0.015 ether}(tokenId);
   ```

## Troubleshooting

### Error: "Insufficient funds for gas"
- Get testnet tokens from the faucet: https://faucet.celo.org/alfajores
- Check your balance: `cast balance YOUR_ADDRESS --rpc-url $CELO_TESTNET_RPC_URL`

### Error: "Contract verification failed"
- Make sure you have a valid Celoscan API key
- Check that the contract source code matches
- Try verifying manually on https://alfajores.celoscan.io

### Error: "Nonce too high"
- Your transactions may be out of order
- Wait for pending transactions to complete
- Or manually set the nonce

## Next Steps

Once you've tested everything on testnet:

1. Verify all functionality works correctly
2. Test edge cases and error handling
3. Review gas costs
4. When ready, deploy to Celo Mainnet (see `DEPLOYMENT.md`)

## Support

For issues or questions:
- Check the contract documentation in the code
- Review the test files for usage examples
- Visit Celo documentation: https://docs.celo.org
- Celo Discord: https://chat.celo.org

