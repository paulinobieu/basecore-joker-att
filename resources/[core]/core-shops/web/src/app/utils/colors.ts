export interface ThemeColors {
	primaryColor: string;
	secondaryColor: string;
	thirdyColor: string;
}

function hexToRgb(hex: string): string | null {
	let value = hex.replace("#", "").trim();

	if (value.length === 3) {
		value = value
			.split("")
			.map((char) => char + char)
			.join("");
	}

	if (value.length !== 6) return null;

	const parsed = Number.parseInt(value, 16);
	if (Number.isNaN(parsed)) return null;

	return [(parsed >> 16) & 255, (parsed >> 8) & 255, parsed & 255].join(", ");
}

/** Aplica as cores enviadas pelo servidor nas variaveis CSS do tema. */
export function attributeColorsToHTML(colors: Partial<ThemeColors>) {
	const root = document.documentElement;

	for (const key of Object.keys(colors) as (keyof ThemeColors)[]) {
		const value = colors[key];
		if (!value) continue;

		const rgb = hexToRgb(value);
		if (rgb) root.style.setProperty(`--${key}`, rgb);
	}
}
