import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: "class",
  content: ["./app/**/*.{ts,tsx}", "./components/**/*.{ts,tsx}", "./lib/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        // Base
        ink: "#0F172A", // Deep slate for high legibility
        "ink-soft": "#475569", // Refined slate mute
        canvas: "#F8FAFC",
        // Signature accents, one per bottom-nav tab — and per GD persona
        lavender: { DEFAULT: "#6366F1", soft: "#EEF2FF", deep: "#4F46E5" }, // Practice / You (Indigo-Lavender)
        sage: { DEFAULT: "#10B981", soft: "#ECFDF5", deep: "#059669" }, // Learn / Riya (Emerald-Sage)
        apricot: { DEFAULT: "#F59E0B", soft: "#FFFBEB", deep: "#D97706" }, // Games / Meera (Warm Amber)
        // Ambient gradient stops
        dawn: { peach: "#FFF7ED", lavender: "#F5F3FF", sage: "#ECFDF5" },
      },
      fontFamily: {
        display: ["var(--font-display)", "serif"],
        sans: ["var(--font-sans)", "system-ui", "sans-serif"],
        mono: ["var(--font-mono)", "ui-monospace", "monospace"],
      },
      borderRadius: {
        xl2: "1.25rem",
        "3xl": "1.5rem",
        "4xl": "2rem",
      },
      boxShadow: {
        card: "0 10px 30px -5px rgba(15, 23, 42, 0.05), 0 4px 12px -3px rgba(15, 23, 42, 0.03)",
        "card-hover": "0 20px 40px -15px rgba(99, 102, 241, 0.15), 0 8px 16px -6px rgba(15, 23, 42, 0.06)",
        "glow-lavender": "0 8px 25px -5px rgba(99, 102, 241, 0.35)",
        "glow-sage": "0 8px 25px -5px rgba(16, 185, 129, 0.35)",
        "glow-apricot": "0 8px 25px -5px rgba(245, 158, 11, 0.35)",
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
