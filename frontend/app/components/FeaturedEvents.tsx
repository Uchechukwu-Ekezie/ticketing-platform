'use client'

import { useAppKit } from '@reown/appkit/react'
import { useAccount } from 'wagmi'

export function FeaturedEvents() {
  const { open } = useAppKit()
  const { isConnected } = useAccount()

  const events = [
    {
      id: 1,
      title: "Summer Music Festival 2025",
      date: "July 15-17, 2025",
      location: "Central Park, NYC",
      price: "0.05 ETH",
      usdPrice: "$120",
      image: "🎵",
      available: "500",
      category: "Music"
    },
    {
      id: 2,
      title: "Tech Conference 2025",
      date: "August 20, 2025",
      location: "Convention Center, SF",
      price: "0.08 ETH",
      usdPrice: "$192",
      image: "💻",
      available: "250",
      category: "Tech"
    },
    {
      id: 3,
      title: "Art Exhibition Opening",
      date: "September 5, 2025",
      location: "Modern Art Museum, LA",
      price: "0.03 ETH",
      usdPrice: "$72",
      image: "🎨",
      available: "150",
      category: "Art"
    }
  ]

  return (
    <section id="events" className="py-20 px-4 sm:px-6 lg:px-8 bg-gray-900">
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold text-white mb-4">
            Featured Events
          </h2>
          <p className="text-xl text-gray-400 max-w-2xl mx-auto">
            Discover amazing events happening near you
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {events.map((event) => (
            <div
              key={event.id}
              className="group bg-black rounded-2xl border border-gray-800 overflow-hidden hover:border-purple-500/50 transition-all hover:shadow-2xl hover:shadow-purple-500/20"
            >
              <div className="relative h-56 bg-linear-to-br from-purple-600 to-blue-600 flex items-center justify-center text-8xl overflow-hidden">
                <div className="absolute inset-0 bg-linear-to-t from-black/60 to-transparent"></div>
                <span className="relative z-10 transform group-hover:scale-110 transition-transform">{event.image}</span>
                <div className="absolute top-4 left-4 px-3 py-1 bg-black/50 backdrop-blur-sm rounded-full text-sm text-white font-medium border border-gray-700">
                  {event.category}
                </div>
              </div>
              <div className="p-6">
                <h3 className="text-xl font-bold text-white mb-4 group-hover:text-purple-400 transition-colors">
                  {event.title}
                </h3>
                <div className="space-y-2 mb-6">
                  <p className="text-gray-400 flex items-center gap-2 text-sm">
                    <span>📅</span> {event.date}
                  </p>
                  <p className="text-gray-400 flex items-center gap-2 text-sm">
                    <span>📍</span> {event.location}
                  </p>
                  <p className="text-gray-400 flex items-center gap-2 text-sm">
                    <span>🎟️</span> {event.available} tickets available
                  </p>
                </div>
                <div className="flex items-center justify-between pt-4 border-t border-gray-800">
                  <div>
                    <div className="text-2xl font-bold text-white mb-1">
                      {event.price}
                    </div>
                    <div className="text-sm text-gray-500">≈ {event.usdPrice}</div>
                  </div>
                  {isConnected ? (
                    <button className="px-6 py-3 text-sm font-semibold text-white bg-linear-to-r from-purple-600 to-blue-600 rounded-xl hover:from-purple-700 hover:to-blue-700 transition-all shadow-lg shadow-purple-500/30 hover:shadow-purple-500/50">
                      Buy Ticket
                    </button>
                  ) : (
                    <button
                      onClick={() => open()}
                      className="px-6 py-3 text-sm font-semibold text-white bg-linear-to-r from-purple-600 to-blue-600 rounded-xl hover:from-purple-700 hover:to-blue-700 transition-all shadow-lg shadow-purple-500/30 hover:shadow-purple-500/50"
                    >
                      Connect
                    </button>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
