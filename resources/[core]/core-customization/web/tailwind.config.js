/** @type {import('tailwindcss').Config} */
function withOpacity(variableName) {
	return ({ opacityValue }) => {
		if (opacityValue !== undefined) {
			return `rgba(var(${variableName}), ${opacityValue})`;
		}
		return `rgb(var(${variableName}))`;
	};
}

export default {
	darkMode: "class",
	content: ["./index.html", "./src/**/*.{ts,tsx}"],
	theme: {
		fontFamily: {
			montserrat: ["Montserrat", "Arial", "sans-serif"],
			poppins: ["Poppins", "Arial", "sans-serif"],
		},
		screens: {
			sm: "640px",
			md: "768px",
			lg: "1024px",
			xl: "1280px",
			"2xl": "1536px",
			"3xl": "1920px",
			"4xl": "2560px",
		},
		extend: {
			colors: {
				primaryColor: withOpacity("--primaryColor"),
				secondaryColor: withOpacity("--secondaryColor"),
				thirdyColor: withOpacity("--thirdyColor"),

				// Tons de texto do tema: cheio, rebaixado, apagado e fantasma.
				ink: {
					DEFAULT: "#EDEAE5",
					muted: "#EDEAE5B2",
					faint: "#EDEAE599",
					ghost: "#EDEAE54D",
				},
			},
			// Superficies e gradientes vivem em custom properties no
			// index.css; aqui viram utilitarios (bg-panel, bg-accent, ...).
			backgroundImage: {
				accent: "var(--gradient-accent)",
				"accent-soft": "var(--gradient-accent-soft)",
				"accent-faint": "var(--gradient-accent-faint)",
				"accent-solid": "var(--gradient-accent-solid)",
				outline: "var(--gradient-outline)",
				panel: "var(--surface-panel)",
				raise: "var(--surface-raise)",
				field: "var(--surface-field)",
				card: "var(--surface-card)",
				overlay: "var(--surface-overlay)",
				toast: "var(--surface-toast)",
				ghost: "var(--surface-ghost)",
				"ghost-hover": "var(--surface-ghost-hover)",
			},
			boxShadow: {
				glow: "0 0 .625rem 0 rgba(var(--primaryColor), .651)",
				"glow-sm": "0 0 .375rem 0 rgba(var(--primaryColor), .65)",
				"glow-lg": "0 0 .75rem 0 rgba(var(--primaryColor), .9)",
				overlay: "0 .25rem .75rem 0 rgba(0, 0, 0, .35)",
				tooltip: "0 .25rem .625rem 0 rgba(0, 0, 0, .4)",
			},
			borderRadius: {
				surface: ".3125rem",
				field: ".25rem",
			},
			keyframes: {
				fade: {
					"0%": { opacity: "0" },
					"100%": { opacity: "1" },
				},
				rise: {
					"0%": { opacity: "0", transform: "translateY(2.5rem)" },
					"100%": { opacity: "1", transform: "translateY(0)" },
				},
				"rise-far": {
					"0%": { opacity: "0", transform: "translateY(7.5rem)" },
					"100%": { opacity: "1", transform: "translateY(0)" },
				},
			},
			animation: {
				fade: "fade .5s ease forwards",
				"fade-fast": "fade .2s ease forwards",
				rise: "rise .45s ease forwards",
				"rise-far": "rise-far .5s ease forwards",
			},
		},
	},
	plugins: [],
};
