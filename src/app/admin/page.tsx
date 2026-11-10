import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'

export default async function AdminDashboard() {
  const supabase = createClient()
  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    redirect('/admin/login')
  }

  // Fetch stats for dashboard
  const { count: pendingOrders } = await supabase
    .from('orders')
    .select('*', { count: 'exact', head: true })
    .in('order_status', ['PESANAN DITERIMA', 'DIKONFIRMASI'])

  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-6">Admin Dashboard</h1>
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
        <div className="bg-white p-6 rounded-xl shadow-sm border border-l-4 border-l-orange-500">
          <h3 className="text-gray-500 text-sm font-medium">Menunggu Konfirmasi</h3>
          <p className="text-3xl font-bold">{pendingOrders}</p>
        </div>
      </div>
      
      {/* Realtime orders table goes here */}
      <div className="bg-white rounded-xl shadow-sm border p-6">
        <h2 className="text-lg font-bold mb-4">Pesanan Masuk (Realtime)</h2>
        <p className="text-sm text-gray-500">Implementasi Supabase Realtime di komponen Client.</p>
      </div>
    </div>
  )
}
