import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}", "./lib/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        // Base
        ink: "#2B2A3D", // deep plum-grey, not pure black — warmer
        "ink-soft": "#6B6980",
        canvas: "#F6F4FB",
        // Signature accents, one per bottom-nav tab — and per GD persona
        lavender: { DEFAULT: "#6F6BC7", soft: "#EDEBFB", deep: "#524FA0" }, // Practice / You
        sage: { DEFAULT: "#5FA88E", soft: "#E7F3EE", deep: "#3E7E68" }, // Learn / Riya (calm)
        apricot: { DEFAULT: "#E7A66D", soft: "#FCEFE1", deep: "#C97E3F" }, // Games / Meera (bold)
        // Ambient gradient stops
        dawn: { peach: "#FDEEDF", lavender: "#EFEBFB", sage: "#E7F2EE" },
      },
      fontFamily: {
        display: ["var(--font-display)", "serif"],
        sans: ["var(--font-sans)", "system-ui", "sans-serif"],
        mono: ["var(--font-mono)", "ui-monospace", "monospace"],
      },
      borderRadius: {
        xl2: "1.25rem",
        "4xl": "2rem",
      },
      boxShadow: {
        card: "0 8px 30px -12px rgba(111,107,199,0.25)",
        "glow-lavender": "0 6px 20px -6px rgba(111,107,199,0.55)",
        "glow-sage": "0 6px 20px -6px rgba(95,168,142,0.55)",
        "glow-apricot": "0 6px 20px -6px rgba(231,166,109,0.55)",
      },
      keyframes: {
        drift: {
          "0%": { transform: "translate(0, 0) scale(1)" },
          "50%": { transform: "translate(2%, -3%) scale(1.06)" },
          "100%": { transform: "translate(-2%, 2%) scale(1)" },
        },
        driftSlow: {
          "0%": { transform: "translate(0, 0) scale(1)" },
          "50%": { transform: "translate(-3%, 3%) scale(1.08)" },
          "100%": { transform: "translate(3%, -2%) scale(1)" },
        },
        wave: {
          "0%, 100%": { transform: "scaleY(0.3)" },
          "50%": { transform: "scaleY(1)" },
        },
        rise: {
          "0%": { opacity: "0", transform: "translateY(8px)" },
          "100%": { opacity: "1", transform: "translateY(0)" },
        },
      },
      animation: {
        drift: "drift 22s ease-in-out infinite alternate",
        "drift-slow": "driftSlow 30s ease-in-out infinite alternate",
        wave: "wave 0.9s ease-in-out infinite",
        rise: "rise 0.4s ease-out both",
      },
    },
  },
  plugins: [],
};
export default config;
