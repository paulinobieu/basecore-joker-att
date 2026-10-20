/** @type {import('tailwindcss').Config} */
export default {
	darkMode: "class",
	content: [
		"./src/**/*.{ts,tsx}",
	],
	theme: {
		extend: {
			colors: {
				theme: "var(--theme-color)",
			},
		},
	},
	plugins: [],
};
