# Quick Deploy to Celo Alfajores Testnet

## 1. Get Testnet Tokens
Visit: https://faucet.celo.org/alfajores

## 2. Create .env file
```bash
cd smartcontract
cat > .env << EOF
PRIVATE_KEY=your_private_key_here
CELO_TESTNET_RPC_URL=https://alfajores-forno.celo-testnet.org
CELOSCAN_API_KEY=your_celoscan_api_key_here
EOF
```

## 3. Deploy
```bash
source .env
forge script script/TicketingPlatform.s.sol:TicketingPlatformScript \
  --rpc-url $CELO_TESTNET_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $CELOSCAN_API_KEY
```

## Celo Alfajores Testnet
- **Chain ID**: 44787
- **RPC**: https://alfajores-forno.celo-testnet.org
- **Explorer**: https://alfajores.celoscan.io
- **Faucet**: https://faucet.celo.org/alfajores

See `DEPLOY_TESTNET.md` for detailed instructions.

