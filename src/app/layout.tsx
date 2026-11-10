import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Cafe Ordering System",
  description: "Modern Fullstack Cafe Ordering System",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="id">
      <body className="bg-gray-50 text-gray-900 font-sans antialiased">
        {children}
      </body>
    </html>
  );
}
