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

				// Tons de texto do tema: cheio, rebaixado, apagado e fantasma.
				ink: {
					DEFAULT: "#EDEAE5",
					muted: "#EDEAE5B2",
					faint: "#EDEAE599",
					ghost: "#EDEAE54D",
				},

				positive: "#5BB376",
				negative: "#E24040",
			},
		},
	},
	plugins: [],
};
