# Quick Deployment Guide - Celo Mainnet

## Quick Setup

1. **Create `.env` file**:
```bash
cd smartcontract
cat > .env << EOF
PRIVATE_KEY=your_private_key_here
CELO_RPC_URL=https://forno.celo.org
CELOSCAN_API_KEY=your_celoscan_api_key_here
EOF
```

2. **Deploy to Celo Mainnet**:
```bash
forge script script/TicketingPlatform.s.sol:TicketingPlatformScript \
  --rpc-url $CELO_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $CELOSCAN_API_KEY
```

Or use environment variables:
```bash
source .env
forge script script/TicketingPlatform.s.sol:TicketingPlatformScript \
  --rpc-url $CELO_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $CELOSCAN_API_KEY
```

## Celo Mainnet Details

- **Chain ID**: 42220
- **RPC**: https://forno.celo.org
- **Block Explorer**: https://celoscan.io
- **Currency**: CELO

## Important Notes

- Ensure your wallet has CELO tokens for gas fees
- Never commit your `.env` file
- Test on Celo Alfajores testnet first if possible

See `DEPLOYMENT.md` for detailed instructions.

