'use client'

import { useAppKit } from '@reown/appkit/react'
import { useAccount } from 'wagmi'

export function Hero() {
  const { open } = useAppKit()
  const { isConnected } = useAccount()

  return (
    <section className="pt-32 pb-20 px-4 sm:px-6 lg:px-8 bg-linear-to-b from-gray-900 via-gray-900 to-black">
      <div className="max-w-7xl mx-auto">
        <div className="text-center">
          {/* Floating badge */}
          <div className="inline-flex items-center gap-2 px-4 py-2 bg-gray-800/50 backdrop-blur-sm border border-gray-700 rounded-full mb-8">
            <span className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></span>
            <span className="text-sm text-gray-300 font-medium">Powered by Blockchain Technology</span>
          </div>

          <h1 className="text-5xl md:text-7xl lg:text-8xl font-bold text-white mb-6 leading-tight">
            Decentralized Event
            <br />
            <span className="bg-linear-to-r from-purple-400 via-purple-500 to-blue-500 bg-clip-text text-transparent">
              Ticketing Platform
            </span>
          </h1>
          
          <p className="text-xl md:text-2xl text-gray-400 mb-12 max-w-3xl mx-auto leading-relaxed">
            Buy, sell, and manage event tickets securely on the blockchain. 
            No middlemen, no fraud, just seamless ticket ownership.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center mb-20">
            {!isConnected ? (
              <button
                onClick={() => open()}
                className="px-8 py-4 text-lg font-semibold text-white bg-linear-to-r from-purple-600 to-blue-600 rounded-xl hover:from-purple-700 hover:to-blue-700 transition-all shadow-2xl shadow-purple-500/30 hover:shadow-purple-500/50 transform hover:scale-105"
              >
                Connect Wallet to Start
              </button>
            ) : (
              <button
                className="px-8 py-4 text-lg font-semibold text-white bg-linear-to-r from-purple-600 to-blue-600 rounded-xl hover:from-purple-700 hover:to-blue-700 transition-all shadow-2xl shadow-purple-500/30 hover:shadow-purple-500/50 transform hover:scale-105"
              >
                Browse Events
              </button>
            )}
            
            <button className="px-8 py-4 text-lg font-semibold text-gray-300 bg-gray-800 border-2 border-gray-700 rounded-xl hover:border-purple-500 hover:text-white hover:bg-gray-700 transition-all">
              Learn More
            </button>
          </div>

          {/* Stats */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8 max-w-5xl mx-auto">
            {[
              { value: '10K+', label: 'Tickets Sold' },
              { value: '500+', label: 'Events' },
              { value: '5K+', label: 'Users' },
              { value: '100%', label: 'Secure' }
            ].map((stat, index) => (
              <div key={index} className="text-center p-6 bg-gray-800/30 backdrop-blur-sm rounded-xl border border-gray-800 hover:border-gray-700 transition-colors">
                <div className="text-4xl md:text-5xl font-bold bg-linear-to-r from-purple-400 to-blue-400 bg-clip-text text-transparent mb-2">
                  {stat.value}
                </div>
                <div className="text-gray-400 font-medium">{stat.label}</div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  )
}
