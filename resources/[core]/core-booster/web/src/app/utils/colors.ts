export interface ThemeColors {
	primaryColor: string;
	secondaryColor: string;
	thirdyColor: string;
}

/** Converte `#ff0000` no triplo `255, 0, 0` que as variaveis CSS esperam. */
export function hexToRgb(hex: string): string | null {
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

/**
 * Escurece um hex e ja devolve no formato das variaveis CSS. E o que fecha o
 * par do gradiente quando o beneficio traz uma cor propria, no lugar do
 * secundario do tema.
 */
export function shadeHex(hex: string, factor = 0.62): string | null {
	const rgb = hexToRgb(hex);
	if (!rgb) return null;

	return rgb
		.split(", ")
		.map((channel) => Math.round(Number(channel) * factor))
		.join(", ");
}

/**
 * Variaveis de cor de um bloco. Sem `accent`, ou com hex invalido, devolve
 * vazio e o bloco herda o destaque do servidor pelo `:root`.
 */
export function accentVars(accent?: string): Record<string, string> {
	if (!accent) return {};

	const color = hexToRgb(accent);
	const shade = shadeHex(accent);

	if (!color || !shade) return {};

	return { "--cardColor": color, "--cardShade": shade };
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
