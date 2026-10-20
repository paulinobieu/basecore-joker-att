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
	content: [
		"./pages/**/*.{ts,tsx}",
		"./components/**/*.{ts,tsx}",
		"./app/**/*.{ts,tsx}",
		"./src/**/*.{ts,tsx}",
	],
	theme: {
		extend: {
			keyframes: {
				progress: {
					"0%": { width: "0%" },
					"100%": { width: "100%" },
				},
				fadeIn: {
					"0%": { opacity: "0" },
					"100%": { opacity: "1" },
				},
				slideUp: {
					"0%": { opacity: "0", transform: "translateY(20px) scale(0.95)" },
					"100%": { opacity: "1", transform: "translateY(0) scale(1)" },
				},
			},
			animation: {
				fadeIn: "fadeIn 0.3s ease-out forwards",
				slideUp: "slideUp 0.4s ease-out 0.1s forwards",
			},
			colors: {
				primaryColor: withOpacity("--primaryColor"),
				secondaryColor: withOpacity("--secondaryColor"),
				thirdColor: withOpacity("--thirdColor"),
			},
		},
	},
	plugins: [],
};
