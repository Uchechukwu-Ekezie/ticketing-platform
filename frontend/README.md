# Event Ticketing Platform - Landing Page

A decentralized event ticketing platform built with Next.js 14, TypeScript, Tailwind CSS, and Reown AppKit (WalletConnect).

## Features

- 🔐 **WalletConnect Integration**: Seamless wallet connection using Reown AppKit
- 🎨 **Modern UI**: Beautiful, responsive design with Tailwind CSS
- ⚡ **Next.js 14**: Latest features including App Router and Server Components
- 🔗 **Multi-Chain Support**: Support for Ethereum, Polygon, Arbitrum, Base, and Optimism
- 📱 **Mobile Responsive**: Fully responsive design for all devices

## Getting Started

### Prerequisites

- Node.js 18+ installed
- A wallet (MetaMask, WalletConnect compatible wallet, etc.)
- Reown Project ID (get it from https://cloud.reown.com)

### Installation

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
Create a `.env.local` file in the frontend directory and add your Reown Project ID:
```env
NEXT_PUBLIC_PROJECT_ID=your_project_id_here
```

To get your Project ID:
- Go to https://cloud.reown.com
- Sign up or log in
- Create a new project
- Copy your Project ID

4. Run the development server:
```bash
npm run dev
```

5. Open [http://localhost:3000](http://localhost:3000) in your browser

## Project Structure

```
frontend/
├── app/
│   ├── components/
│   │   ├── Header.tsx          # Navigation with wallet connect button
│   │   ├── Hero.tsx            # Hero section with main CTA
│   │   ├── Features.tsx        # Platform features showcase
│   │   ├── HowItWorks.tsx      # Step-by-step guide
│   │   ├── FeaturedEvents.tsx  # Featured events display
│   │   └── Footer.tsx          # Footer with links
│   ├── context/
│   │   └── Web3Modal.tsx       # Reown AppKit configuration
│   ├── layout.tsx              # Root layout with providers
│   ├── page.tsx                # Main landing page
│   └── globals.css             # Global styles
├── .env.local                  # Environment variables
└── package.json
```

## Technologies Used

- **Framework**: Next.js 14 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS v4
- **Web3**: 
  - @reown/appkit
  - @reown/appkit-adapter-wagmi
  - wagmi
  - viem
- **State Management**: @tanstack/react-query

## Features Explained

### WalletConnect Integration
The platform uses Reown AppKit (formerly WalletConnect) for secure wallet connections. Users can connect with:
- MetaMask
- WalletConnect compatible wallets
- Coinbase Wallet
- And many more...

### Multi-Chain Support
Currently supports:
- Ethereum Mainnet
- Polygon
- Arbitrum
- Base
- Optimism

### Components

1. **Header**: Fixed navigation bar with wallet connection
2. **Hero**: Main landing section with key messaging and CTAs
3. **Features**: Showcase of platform benefits
4. **How It Works**: 4-step guide to using the platform
5. **Featured Events**: Display of upcoming events with purchase options
6. **Footer**: Links and additional information

## Customization

### Update Chain Configuration
Edit `app/context/Web3Modal.tsx` to add/remove blockchain networks:

```typescript
const wagmiAdapter = new WagmiAdapter({
  projectId,
  networks: [mainnet, arbitrum, polygon, base, optimism, /* add more */]
})
```

### Styling
All components use Tailwind CSS. Update the color scheme by modifying the gradient colors throughout the components.

## Building for Production

```bash
npm run build
npm start
```

## Next Steps

- [ ] Integrate smart contracts
- [ ] Add event creation functionality
- [ ] Implement ticket purchasing logic
- [ ] Add user dashboard
- [ ] Integrate IPFS for ticket metadata
- [ ] Add secondary marketplace

## License

MIT

## Support

For issues and questions, please open an issue on GitHub or contact the development team.

