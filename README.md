# ☕ Warung Umi / Cafe Ordering System

Sistem pemesanan cafe full-stack menggunakan Next.js (App Router), Supabase (PostgreSQL, Auth, Storage, Realtime), dan Tailwind CSS.

## 🚀 Fitur Utama
1. **Customer Website:** Menu, Cart, Checkout, QRIS / Cash, Live Tracking.
2. **Admin Dashboard:** Manajemen Pesanan Realtime, Menu, Kategori, QRIS, Meja, dan Reset Nomor Antrian.
3. **Database & Keamanan:** Row Level Security (RLS), Fungsi Atomic untuk Nomor Pesanan (ORD-001) reset harian, Autentikasi Admin.

## 🛠 Panduan Instalasi & Setup

### 1. Persiapan Supabase
- Buat project baru di [Supabase](https://supabase.com/).
- Jalankan query dari `supabase/migrations/01_schema.sql` di SQL Editor Supabase untuk membuat tabel, policy RLS, dan function.
- Masuk ke **Authentication** > Providers, pastikan Email enabled.
- Masuk ke **Storage**, buat bucket bernama `cafe-assets` (jadikan public).

### 2. Setup Environment Variables
Copy `.env.example` menjadi `.env.local` dan isi dengan kredensial Supabase Anda.

### 3. Instalasi dan Menjalankan Lokal
```bash
npm install
npm run dev
```
Buka `http://localhost:3000` untuk Customer Website dan `http://localhost:3000/admin` untuk Admin Dashboard.

### 4. Membuat Akun Admin
Karena tidak ada register untuk umum, buat akun admin langsung via Supabase Dashboard -> Authentication -> Add User. 

### 5. Deployment ke Vercel
1. Upload kode ini ke repository GitHub Anda.
2. Login ke [Vercel](https://vercel.com/) dan buat project baru dari repository tersebut.
3. Tambahkan Environment Variables (`NEXT_PUBLIC_SUPABASE_URL` dan `NEXT_PUBLIC_SUPABASE_ANON_KEY`) di menu Settings Vercel.
4. Klik **Deploy**.
