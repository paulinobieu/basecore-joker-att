export interface ColorTriad {
	primaryColor: string;
	secondaryColor: string;
	thirdyColor: string;
}

export const ColorVariants = {
	pink: "#ff95b7",
	yellow: "#ffcf30",
	green: "#3df76e",
	cyan: "#39eaff",
	lavender: "#edb4ff",
	magenta: "#ff90ed",
	gray: "#c5c5c5",
	CORE: {
		primaryColor: "#df155b",
		secondaryColor: "#9e0e40",
		thirdyColor: "#660929",
	},
};

function hexToRgb(hex: string): string {
	const bigint = Number.parseInt(hex.slice(1), 16);
	const r = (bigint >> 16) & 255;
	const g = (bigint >> 8) & 255;
	const b = bigint & 255;

	return `${r},${g},${b}`;
}

function darkenHex(hex: string, amount: number): string {
	const bigint = Number.parseInt(hex.replace("#", ""), 16);
	const r = Math.max(0, Math.round(((bigint >> 16) & 255) * (1 - amount)));
	const g = Math.max(0, Math.round(((bigint >> 8) & 255) * (1 - amount)));
	const b = Math.max(0, Math.round((bigint & 255) * (1 - amount)));

	return `#${((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)}`;
}

function setColors(triad: ColorTriad) {
	const el = document.documentElement;

	el.style.setProperty("--primaryColor", hexToRgb(triad.primaryColor));
	el.style.setProperty("--secondaryColor", hexToRgb(triad.secondaryColor));
	el.style.setProperty("--thirdyColor", hexToRgb(triad.thirdyColor));
	el.style.setProperty("--primary", triad.primaryColor);
	el.style.setProperty("--primary-hover", darkenHex(triad.primaryColor, 0.12));
}

export function applyServerColors(
	color: ColorTriad | keyof typeof ColorVariants,
) {
	if (typeof color === "string") {
		const variant = ColorVariants[color];

		if (!variant) return;

		if (typeof variant === "string") {
			return setColors({
				primaryColor: variant,
				secondaryColor: variant,
				thirdyColor: variant,
			});
		}

		return setColors(variant);
	}

	if (color?.primaryColor && color.secondaryColor && color.thirdyColor) {
		setColors(color);
	}
}

/**
 * O client ainda pode mandar o formato antigo (primary_color,
 * secondary_color, shadow_color). Normaliza para a triade.
 */
export function normalizeServerColors(colors: any): ColorTriad | null {
	if (!colors) return null;

	const primaryColor = colors.primaryColor ?? colors.primary_color;
	const secondaryColor = colors.secondaryColor ?? colors.secondary_color;
	const thirdyColor =
		colors.thirdyColor ?? colors.thirdy_color ?? colors.shadow_color;

	if (!primaryColor || !secondaryColor || !thirdyColor) return null;

	return { primaryColor, secondaryColor, thirdyColor };
}

/**
 * O payload do client pode vir embrulhado numa chave que muda por
 * recurso. Acha o objeto de cores sem depender do nome do embrulho.
 */
export function resolveServerColors(data: any): any {
	if (!data) return null;

	if (data.colors) return data.colors;

	for (const key of Object.keys(data)) {
		const value = data[key];

		if (value && typeof value === "object" && value.colors) return value.colors;
	}

	return data;
}
