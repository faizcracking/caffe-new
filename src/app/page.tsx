import { createClient } from '@/lib/supabase/server'
import Link from 'next/link'

export default async function Home() {
  const supabase = createClient()
  const { data: products } = await supabase.from('products').select('*').eq('is_available', true)

  return (
    <main className="max-w-4xl mx-auto p-4 md:p-8">
      <header className="text-center mb-10">
        <h1 className="text-4xl font-bold tracking-tight mb-2 text-primary">☕ Warung Umi</h1>
        <p className="text-gray-500">Pesan langsung dari meja Anda.</p>
      </header>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {products?.map((product) => (
          <div key={product.id} className="bg-white rounded-xl shadow-sm border overflow-hidden p-4">
            <div className="h-40 bg-gray-200 rounded-lg mb-4 flex items-center justify-center">
              {product.image_url ? (
                <img src={product.image_url} alt={product.name} className="object-cover w-full h-full rounded-lg" />
              ) : (
                <span className="text-gray-400">No Image</span>
              )}
            </div>
            <h2 className="font-semibold text-lg">{product.name}</h2>
            <p className="text-sm text-gray-500 mb-4 line-clamp-2">{product.description}</p>
            <div className="flex justify-between items-center">
              <span className="font-bold">Rp {product.price.toLocaleString('id-ID')}</span>
              <button className="bg-primary text-white px-4 py-2 rounded-lg text-sm font-medium hover:bg-blue-700 transition">
                Tambah
              </button>
            </div>
          </div>
        ))}
      </div>
      
      {/* Floating Cart Button */}
      <Link href="/cart" className="fixed bottom-6 right-6 bg-primary text-white p-4 rounded-full shadow-lg hover:shadow-xl transition-all">
        Lihat Keranjang
      </Link>
    </main>
  )
}
