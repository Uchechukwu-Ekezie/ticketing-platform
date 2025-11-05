export function Features() {
  const features = [
    {
      icon: "🔒",
      title: "Secure & Transparent",
      description: "All tickets are minted as NFTs on the blockchain, ensuring authenticity and preventing fraud."
    },
    {
      icon: "💰",
      title: "Lower Fees",
      description: "No middlemen means lower transaction fees. More money goes to event organizers and artists."
    },
    {
      icon: "🔄",
      title: "Easy Resale",
      description: "Resell your tickets securely on our marketplace with smart contract-enforced price caps."
    },
    {
      icon: "🎟️",
      title: "True Ownership",
      description: "Your ticket is your property. Transfer, gift, or sell it as you please with full control."
    },
    {
      icon: "⚡",
      title: "Instant Transfer",
      description: "Send tickets to friends instantly without waiting for physical delivery or email confirmations."
    },
    {
      icon: "🌐",
      title: "Multi-Chain Support",
      description: "Works across multiple blockchains including Ethereum, Polygon, and more."
    }
  ]

  return (
    <section id="features" className="py-20 px-4 sm:px-6 lg:px-8 bg-black border-t border-gray-800">
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold text-white mb-4">
            Why Choose TicketChain?
          </h2>
          <p className="text-xl text-gray-400 max-w-2xl mx-auto">
            Experience the future of event ticketing with blockchain technology
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
          {features.map((feature, index) => (
            <div
              key={index}
              className="group bg-gray-900 p-8 rounded-2xl border border-gray-800 hover:border-purple-500/50 transition-all hover:shadow-2xl hover:shadow-purple-500/10"
            >
              <div className="text-5xl mb-5 transform group-hover:scale-110 transition-transform">{feature.icon}</div>
              <h3 className="text-xl font-bold text-white mb-3 group-hover:text-purple-400 transition-colors">
                {feature.title}
              </h3>
              <p className="text-gray-400 leading-relaxed">
                {feature.description}
              </p>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
