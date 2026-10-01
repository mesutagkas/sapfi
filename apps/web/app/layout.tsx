import type { Metadata, Viewport } from "next";
import SiteInteractions from "@/components/SiteInteractions";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL(process.env.APP_URL ?? "http://localhost:3000"),
  title: { default: "Depar — Stoksuz satış platformu", template: "%s — Depar" },
  description: "Tedarikçinin ürünü, senin mağazanda. Stok tutmadan Trendyol, Hepsiburada ve N11'de sat.",
  icons: { icon: "/favicon.svg" },
  openGraph: {
    type: "website",
    siteName: "Depar",
    title: "Depar — Stoksuz satış platformu",
    description: "Stok tutma. Kargolama. Sadece sat.",
  },
};

export const viewport: Viewport = { themeColor: "#0A1733" };

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="tr">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
        <link
          href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700;800;900&display=swap"
          rel="stylesheet"
        />
        {/* JavaScript çalışmazsa animasyonla gelen içerik gizli kalmasın. */}
        <noscript>
          <style>{".rv{opacity:1!important;transform:none!important}"}</style>
        </noscript>
      </head>
      <body>
        {children}
        <SiteInteractions />
      </body>
    </html>
  );
}
