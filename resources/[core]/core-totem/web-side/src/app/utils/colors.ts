const DEFAULT_COLOR = "#0143bb";

function normalizeHex(value: string): string {
	return /^#[0-9a-f]{6}$/i.test(value) ? value : DEFAULT_COLOR;
}

function hexToRgb(value: string): [number, number, number] {
	const hex = normalizeHex(value).slice(1);
	return [
		Number.parseInt(hex.slice(0, 2), 16),
		Number.parseInt(hex.slice(2, 4), 16),
		Number.parseInt(hex.slice(4, 6), 16),
	];
}

function mix(color: [number, number, number], target: number, ratio: number) {
	return color
		.map((channel) => Math.round(channel + (target - channel) * ratio))
		.join(", ");
}

export function applyThemeColor(themeColor: string) {
	const rgb = hexToRgb(themeColor);
	document.documentElement.style.setProperty("--primaryColor", rgb.join(", "));
	document.documentElement.style.setProperty(
		"--secondaryColor",
		mix(rgb, 0, 0.62),
	);
	document.documentElement.style.setProperty(
		"--thirdyColor",
		mix(rgb, 255, 0.22),
	);
}
