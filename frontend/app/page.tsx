import { Header } from './components/Header'
import { Hero } from './components/Hero'
import { Features } from './components/Features'
import { HowItWorks } from './components/HowItWorks'
import { FeaturedEvents } from './components/FeaturedEvents'
import { Footer } from './components/Footer'

export default function Home() {
  return (
    <div className="min-h-screen bg-black">
      <Header />
      <Hero />
      <Features />
      <HowItWorks />
      <FeaturedEvents />
      <Footer />
    </div>
  );
}
