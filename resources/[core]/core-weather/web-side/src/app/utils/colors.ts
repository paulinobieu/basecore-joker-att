type RgbTuple = [number, number, number];

function hexToRgb(hex: string): RgbTuple | null {
	const clean = hex.trim().replace(/^#/, "");
	const full =
		clean.length === 3
			? clean
					.split("")
					.map((c) => c + c)
					.join("")
			: clean;
	if (!/^[0-9a-fA-F]{6}$/.test(full)) return null;
	return [
		Number.parseInt(full.slice(0, 2), 16),
		Number.parseInt(full.slice(2, 4), 16),
		Number.parseInt(full.slice(4, 6), 16),
	];
}

function scaleRgb(rgb: RgbTuple, factor: number): string {
	return rgb.map((c) => Math.round(c * factor)).join(", ");
}

export function attributeColorsToHTML(hexColor: string) {
	const rgb = hexToRgb(hexColor);
	if (!rgb) return;

	const root = document.documentElement.style;
	root.setProperty("--primary", hexColor);
	root.setProperty("--primary-rgb", rgb.join(", "));
	root.setProperty("--secondary-rgb", scaleRgb(rgb, 0.78));
	root.setProperty("--thirdy-rgb", scaleRgb(rgb, 0.62));
}
