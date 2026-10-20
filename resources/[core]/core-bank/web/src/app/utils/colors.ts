/**
 * O Lua manda uma cor só; as duas tonalidades escuras saem dela na mesma
 * proporção da identidade (#dc1553 → #9c0f3b → #650a26).
 */
function hexToRgb(hex: string): [number, number, number] | null {
	const value = hex.replace("#", "").trim();
	if (value.length !== 6) return null;

	const channels: [number, number, number] = [
		Number.parseInt(value.substring(0, 2), 16),
		Number.parseInt(value.substring(2, 4), 16),
		Number.parseInt(value.substring(4, 6), 16),
	];

	return channels.some(Number.isNaN) ? null : channels;
}

export function attributeColorsToHTML(color: string) {
	const channels = hexToRgb(color);
	if (!channels) return;

	const shade = (factor: number) =>
		channels.map((channel) => Math.round(channel * factor)).join(", ");

	const root = document.documentElement;

	root.style.setProperty("--primaryColor", channels.join(", "));
	root.style.setProperty("--secondaryColor", shade(0.71));
	root.style.setProperty("--thirdyColor", shade(0.46));
}
