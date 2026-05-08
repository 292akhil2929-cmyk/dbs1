import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        display: ['"Bodoni Moda"', '"Playfair Display"', "serif"],
        mono: ['"JetBrains Mono"', "monospace"],
        sans: ['"Space Grotesk"', "system-ui", "sans-serif"],
      },
      colors: {
        "neon-cyan":   "#29f6ff",
        "neon-purple": "#b14bff",
        "neon-pink":   "#ff3df0",
        "bg-dark":     "#050507",
        "text-warm":   "#f4f1ea",
      },
      letterSpacing: {
        tightest: "-0.04em",
        tighter:  "-0.02em",
      },
      animation: {
        marquee:    "marquee 40s linear infinite",
        "spin-slow":"spin-slow 28s linear infinite",
        "spin-rev": "spin-slow 22s linear infinite reverse",
        leak:       "leak 18s ease-in-out infinite alternate",
        ringp:      "ringp 4s ease-out infinite",
      },
      keyframes: {
        marquee: {
          from: { transform: "translateX(0)" },
          to:   { transform: "translateX(-50%)" },
        },
        "spin-slow": {
          to: { transform: "rotate(360deg)" },
        },
        leak: {
          "0%":   { transform: "translate(0,0) scale(1)" },
          "50%":  { transform: "translate(2%,-1%) scale(1.04)" },
          "100%": { transform: "translate(-2%,2%) scale(0.98)" },
        },
        ringp: {
          "0%":   { transform: "scale(0.4)", opacity: "0" },
          "30%":  { opacity: "0.7" },
          "100%": { transform: "scale(2.4)", opacity: "0" },
        },
      },
    },
  },
  plugins: [],
};

export default config;
