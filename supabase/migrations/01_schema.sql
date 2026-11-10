-- =======================================================
-- CAFE ORDERING SYSTEM - SUPABASE SCHEMA MIGRATION
-- =======================================================

-- 1. TABLES

-- Admin Profiles (extends Auth Users)
CREATE TABLE profiles (
    id UUID REFERENCES auth.users(id) PRIMARY KEY,
    full_name TEXT,
    role TEXT DEFAULT 'admin' CHECK (role IN ('admin', 'superadmin')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Categories
CREATE TABLE categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Products
CREATE TABLE products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    image_url TEXT,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tables (Meja)
CREATE TABLE tables (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    number INTEGER UNIQUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Settings (QRIS, nama toko, dll)
CREATE TABLE settings (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sequence Table untuk Nomor Urut (Reset Harian)
CREATE TABLE order_sequences (
    date DATE PRIMARY KEY DEFAULT (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Jakarta')::DATE,
    last_value INTEGER NOT NULL DEFAULT 0
);

-- Orders
CREATE TABLE orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_number TEXT NOT NULL UNIQUE, -- e.g., ORD-001
    table_number INTEGER NOT NULL,
    tracking_token TEXT UNIQUE NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL,
    payment_method TEXT CHECK (payment_method IN ('CASH', 'QRIS')),
    payment_status TEXT DEFAULT 'BELUM DIBAYAR' CHECK (payment_status IN ('BELUM DIBAYAR', 'MENUNGGU VERIFIKASI', 'LUNAS', 'DIBATALKAN')),
    order_status TEXT DEFAULT 'PESANAN DITERIMA' CHECK (order_status IN ('PESANAN DITERIMA', 'DIKONFIRMASI', 'SEDANG DIBUAT', 'PESANAN SIAP', 'SELESAI', 'DITOLAK')),
    customer_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Order Items
CREATE TABLE order_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    product_name TEXT NOT NULL, -- Snapshot nama produk
    price NUMERIC(10,2) NOT NULL, -- Snapshot harga
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    subtotal NUMERIC(10,2) NOT NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Order Sequence Logs (Untuk tracking reset manual)
CREATE TABLE order_sequence_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    admin_id UUID REFERENCES auth.users(id),
    action TEXT NOT NULL,
    previous_value INTEGER,
    new_value INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. FUNCTIONS

-- Fungsi Atomic untuk Generate Daily Order Number
CREATE OR REPLACE FUNCTION generate_daily_order_number()
RETURNS TEXT AS $$
DECLARE
    today DATE := (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Jakarta')::DATE;
    seq_val INTEGER;
    formatted_num TEXT;
BEGIN
    INSERT INTO order_sequences (date, last_value)
    VALUES (today, 1)
    ON CONFLICT (date)
    DO UPDATE SET last_value = order_sequences.last_value + 1
    RETURNING last_value INTO seq_val;
    
    formatted_num := 'ORD-' || LPAD(seq_val::TEXT, 3, '0');
    RETURN formatted_num;
END;
$$ LANGUAGE plpgsql;

-- 3. ROW LEVEL SECURITY (RLS)

ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- Produk & Kategori bisa dibaca siapa saja, tapi hanya bisa diedit oleh admin
CREATE POLICY "Public read products" ON products FOR SELECT USING (true);
CREATE POLICY "Admin write products" ON products FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Public read categories" ON categories FOR SELECT USING (true);
CREATE POLICY "Admin write categories" ON categories FOR ALL USING (auth.role() = 'authenticated');

-- Orders bisa diinsert oleh siapa saja (customer web), dibaca dengan token, diedit admin
CREATE POLICY "Anyone can insert order" ON orders FOR INSERT WITH CHECK (true);
CREATE POLICY "Read order by token" ON orders FOR SELECT USING (true); -- Di frontend difilter via RPC atau match token
CREATE POLICY "Admin manage orders" ON orders FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Anyone can insert order items" ON order_items FOR INSERT WITH CHECK (true);
CREATE POLICY "Public read order items" ON order_items FOR SELECT USING (true);
CREATE POLICY "Admin manage order items" ON order_items FOR ALL USING (auth.role() = 'authenticated');

-- Settings bisa dibaca publik (untuk QRIS), diedit admin
CREATE POLICY "Public read settings" ON settings FOR SELECT USING (true);
CREATE POLICY "Admin manage settings" ON settings FOR ALL USING (auth.role() = 'authenticated');

-- 4. SEED DATA (Data Demo)
INSERT INTO categories (name, slug) VALUES ('Makanan', 'makanan'), ('Minuman', 'minuman');
INSERT INTO tables (number) VALUES (1), (2), (3), (4), (5);
INSERT INTO settings (key, value) VALUES ('qris_info', '{"image_url": "https://example.com/qris.png", "merchant_name": "Cafe Demo"}');
