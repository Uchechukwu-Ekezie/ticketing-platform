export function HowItWorks() {
  const steps = [
    {
      number: "1",
      title: "Connect Your Wallet",
      description: "Use WalletConnect to securely connect your crypto wallet to our platform."
    },
    {
      number: "2",
      title: "Browse Events",
      description: "Explore upcoming events and find the perfect tickets for your next experience."
    },
    {
      number: "3",
      title: "Purchase Tickets",
      description: "Buy tickets using cryptocurrency. Your ticket is minted as an NFT instantly."
    },
    {
      number: "4",
      title: "Attend & Enjoy",
      description: "Present your NFT ticket at the event for instant verification and entry."
    }
  ]

  return (
    <section id="how-it-works" className="py-20 px-4 sm:px-6 lg:px-8 bg-linear-to-b from-black to-gray-900">
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-bold text-white mb-4">
            How It Works
          </h2>
          <p className="text-xl text-gray-400 max-w-2xl mx-auto">
            Getting started is simple. Follow these easy steps to buy your first blockchain ticket.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-8">
          {steps.map((step, index) => (
            <div key={index} className="relative">
              <div className="text-center group">
                <div className="w-20 h-20 bg-linear-to-r from-purple-600 to-blue-600 rounded-2xl flex items-center justify-center text-white text-3xl font-bold mx-auto mb-6 shadow-2xl shadow-purple-500/30 group-hover:shadow-purple-500/50 transition-all group-hover:scale-110">
                  {step.number}
                </div>
                <h3 className="text-xl font-bold text-white mb-3">
                  {step.title}
                </h3>
                <p className="text-gray-400 leading-relaxed">
                  {step.description}
                </p>
              </div>
              {index < steps.length - 1 && (
                <div className="hidden lg:block absolute top-10 left-full w-full h-0.5 bg-linear-to-r from-purple-600 to-blue-600 opacity-20 -ml-4" />
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}
