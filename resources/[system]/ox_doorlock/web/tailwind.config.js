/** @type {import('tailwindcss').Config} */
export default {
	content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
	theme: {
		extend: {
			colors: {
				primaryColor: "rgba(var(--primaryColor))",
				secondaryColor: "rgba(var(--secondaryColor))",
				thirdyColor: "rgba(var(--thirdyColor))",
			},
			animation: {
				in: "fadeIn .15s ease-out",
				"zoom-in": "zoomIn .15s ease-out",
			},
			keyframes: {
				fadeIn: {
					"0%": { opacity: "0" },
					"100%": { opacity: "1" },
				},
				zoomIn: {
					"0%": { opacity: "0", transform: "scale(0.95)" },
					"100%": { opacity: "1", transform: "scale(1)" },
				},
			},
		},
	},
	plugins: [],
};
