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
	content: ["./src/**/*.{ts,tsx}"],
	theme: {
		extend: {
			colors: {
				primaryColor: withOpacity("--primaryColor"),
				secondaryColor: withOpacity("--secondaryColor"),
				thirdyColor: withOpacity("--thirdyColor"),
				cardColor: withOpacity("--cardColor"),
			},
		},
	},
	plugins: [],
};
