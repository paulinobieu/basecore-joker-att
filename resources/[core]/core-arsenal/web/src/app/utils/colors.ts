/**
 * O Lua do arsenal manda uma cor so -- a primaria, ja convertida para o
 * formato "R, G, B" pelo `ResolveColor` do client. O desenho, porem, usa tres
 * variaveis nos degrades. As outras duas sao derivadas por luminancia.
 *
 * Os fatores nao sao arbitrarios: aplicados ao tema padrao (#dc1553) eles
 * devolvem exatamente a paleta usada no core-shops -- 158,15,60 e 103,10,39.
 * Trocar a cor no config, portanto, mantem a mesma relacao entre os tons.
 */
const SECONDARY_FACTOR = 0.72;
const THIRDY_FACTOR = 0.47;

/** Aceita "220, 21, 83" e tambem "#dc1553", por seguranca. */
function parseRgb(value: string): [number, number, number] | null {
	const raw = value.trim();

	if (raw.startsWith("#")) {
		let hex = raw.slice(1);

		if (hex.length === 3) {
			hex = hex
				.split("")
				.map((char) => char + char)
				.join("");
		}

		if (hex.length !== 6) return null;

		const parsed = Number.parseInt(hex, 16);
		if (Number.isNaN(parsed)) return null;

		return [(parsed >> 16) & 255, (parsed >> 8) & 255, parsed & 255];
	}

	const parts = raw.split(",").map((part) => Number.parseInt(part.trim(), 10));

	if (parts.length !== 3 || parts.some((part) => Number.isNaN(part))) {
		return null;
	}

	return [parts[0], parts[1], parts[2]];
}

const scale = (channels: [number, number, number], factor: number) =>
	channels.map((channel) => Math.round(channel * factor)).join(", ");

/** Aplica a cor enviada pelo servidor nas variaveis CSS do tema. */
export function attributeColorToHTML(value: string) {
	const channels = parseRgb(value);
	if (!channels) return;

	const root = document.documentElement;

	root.style.setProperty("--primaryColor", channels.join(", "));
	root.style.setProperty("--secondaryColor", scale(channels, SECONDARY_FACTOR));
	root.style.setProperty("--thirdyColor", scale(channels, THIRDY_FACTOR));
}
