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
				accent: withOpacity("--accent-color-rgb"),
			},
			fontFamily: {
				outfit: ["Outfit", "sans-serif"],
				mulish: ["Mulish", "sans-serif"],
			},
			keyframes: {
				fadeInScale: {
					from: { opacity: "0", transform: "scale(0.96)" },
					to: { opacity: "1", transform: "scale(1)" },
				},
				fadeOutScale: {
					from: { opacity: "1", transform: "scale(1)" },
					to: { opacity: "0", transform: "scale(0.96)" },
				},
				bnFadeIn: {
					from: { opacity: "0" },
					to: { opacity: "1" },
				},
				bnFadeOut: {
					from: { opacity: "1" },
					to: { opacity: "0" },
				},
				tooltipFadeIn: {
					from: { opacity: "0", transform: "translate(-6px, -50%)" },
					to: { opacity: "1", transform: "translate(0, -50%)" },
				},
				modalOverlayIn: {
					from: { opacity: "0" },
					to: { opacity: "1" },
				},
				modalSlideIn: {
					from: { opacity: "0", transform: "scale(0.95) translateY(8px)" },
					to: { opacity: "1", transform: "scale(1) translateY(0)" },
				},
				"nui-amd-keepalive": {
					"0%, 100%": { opacity: "1" },
					"50%": { opacity: "0.999" },
				},
			},
			animation: {
				fadeInScale: "fadeInScale 0.35s ease-out",
				fadeOutScale: "fadeOutScale 0.25s ease-in forwards",
				bnFadeIn: "bnFadeIn 0.35s ease-out",
				bnFadeOut: "bnFadeOut 0.25s ease-in forwards",
				tooltipFadeIn: "tooltipFadeIn 0.15s ease-out",
				modalOverlayIn: "modalOverlayIn 0.2s ease-out",
				modalSlideIn: "modalSlideIn 0.25s ease-out",
				"nui-amd-keepalive": "nui-amd-keepalive 4s linear infinite",
			},
		},
	},
	plugins: [],
};
