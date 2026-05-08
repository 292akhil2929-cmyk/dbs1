import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "CHRONO-VANDL — Mechanical Anomaly",
  description:
    "A timepiece born from contradiction. Hand-assembled Swiss movement. Titanium Grade-5 case. Limited drop — AED 2,850.",
  keywords: ["luxury watch", "CHRONO-VANDL", "Swiss movement", "titanium", "limited edition", "UAE"],
  openGraph: {
    title: "CHRONO-VANDL — Mechanical Anomaly",
    description: "A timepiece born from contradiction.",
    type: "website",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link
          rel="preconnect"
          href="https://fonts.gstatic.com"
          crossOrigin="anonymous"
        />
        <link
          href="https://fonts.googleapis.com/css2?family=Bodoni+Moda:ital,opsz,wght@0,6..96,400;0,6..96,700;0,6..96,900;1,6..96,400;1,6..96,700;1,6..96,900&family=JetBrains+Mono:wght@300;400;500;700&family=Space+Grotesk:wght@300;400;500;600;700&display=swap"
          rel="stylesheet"
        />
      </head>
      <body>{children}</body>
    </html>
  );
}
