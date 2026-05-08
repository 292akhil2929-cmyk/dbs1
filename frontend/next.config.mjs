/** @type {import('next').NextConfig} */
const nextConfig = {
  output: "export",          // static HTML/CSS/JS — no Node server needed
  basePath: "/dbs1/shop",    // GitHub Pages: https://<user>.github.io/dbs1/shop
  assetPrefix: "/dbs1/shop", // prefix all _next/ asset URLs
  images: {
    unoptimized: true,       // required for static export (no image optimisation server)
    remotePatterns: [
      { protocol: "https", hostname: "images.unsplash.com" },
      { protocol: "https", hostname: "i.pravatar.cc" },
    ],
  },
  trailingSlash: true,       // generates /page/index.html — works better on Pages
};

export default nextConfig;
