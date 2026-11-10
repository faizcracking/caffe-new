'use server'
import { createClient } from '@/lib/supabase/server'
import { v4 as uuidv4 } from 'uuid'

export async function processCheckout(formData: any) {
  const supabase = createClient()
  const trackingToken = uuidv4().replace(/-/g, '').substring(0, 12)
  
  // 1. Get atomic order number via RPC
  const { data: orderNumber, error: rpcError } = await supabase.rpc('generate_daily_order_number')
  
  if (rpcError) throw new Error('Gagal membuat nomor pesanan')

  // 2. Fetch fresh prices from DB for security (Jangan percaya harga dari frontend)
  let totalAmount = 0
  const orderItemsData = []
  
  for (const item of formData.items) {
    const { data: product } = await supabase.from('products').select('name, price').eq('id', item.productId).single()
    if (product) {
      const subtotal = product.price * item.quantity
      totalAmount += subtotal
      orderItemsData.push({
        product_id: item.productId,
        product_name: product.name,
        price: product.price,
        quantity: item.quantity,
        subtotal: subtotal,
        notes: item.notes
      })
    }
  }

  // 3. Insert Order
  const { data: order, error: orderError } = await supabase
    .from('orders')
    .insert({
      order_number: orderNumber,
      table_number: formData.tableNumber,
      tracking_token: trackingToken,
      total_amount: totalAmount,
      payment_method: formData.paymentMethod,
      customer_notes: formData.customerNotes,
      payment_status: formData.paymentMethod === 'CASH' ? 'BELUM DIBAYAR' : 'MENUNGGU VERIFIKASI',
      order_status: 'PESANAN DITERIMA'
    })
    .select('id')
    .single()

  if (orderError) throw new Error(orderError.message)

  // 4. Insert Items
  const itemsWithOrderId = orderItemsData.map(item => ({ ...item, order_id: order.id }))
  await supabase.from('order_items').insert(itemsWithOrderId)

  return { trackingToken, orderNumber }
}
