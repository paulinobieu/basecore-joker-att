/**
 * Símbolo do dinheiro. Vem do Bank.Symbol do Lua no bootstrap e vale para o
 * banco inteiro — saldo, extrato, faturas, aplicações e cotação de cripto.
 */
let symbol = "R$";

export function setSymbol(next: string) {
	if (next) symbol = next;
}

export function currencySymbol() {
	return symbol;
}

/** Valor com o símbolo na frente. É o formato padrão da interface. */
export function formatCurrency(value: unknown): string {
	return `${symbol} ${formatMoney(value)}`;
}

function toNumber(value: unknown): number {
	const numeric = Number(value);
	return Number.isFinite(numeric) ? numeric : 0;
}

/**
 * Os saldos do vRP são inteiros, então o padrão é sem centavos — só faturas e
 * impostos podem chegar quebrados.
 */
export function formatMoney(value: unknown): string {
	const numeric = toNumber(value);
	const decimals = Number.isInteger(numeric) ? 0 : 2;

	return numeric.toLocaleString("pt-BR", {
		minimumFractionDigits: decimals,
		maximumFractionDigits: decimals,
	});
}

/** Abreviação para eixos de gráfico, onde não cabe o número inteiro. */
export function formatCompact(value: number): string {
	const absolute = Math.abs(value);

	if (absolute >= 1_000_000) return `${(value / 1_000_000).toFixed(1)}M`;
	if (absolute >= 1_000) return `${Math.round(value / 1_000)}k`;

	return String(Math.round(value));
}

/** Aceita o que o jogador digita ("1.500", "1500,50") e devolve o número. */
export function parseAmount(text: string): number {
	const cleaned = text
		.replace(/\./g, "")
		.replace(",", ".")
		.replace(/[^\d.]/g, "");
	const numeric = Number.parseFloat(cleaned);

	return Number.isFinite(numeric) && numeric > 0 ? numeric : 0;
}

/** Mantém só o que pode virar valor enquanto o jogador digita. */
export function sanitizeAmount(text: string): string {
	return text.replace(/[^\d.,]/g, "");
}

export function formatPercent(value: number): string {
	return `${value >= 0 ? "+" : ""}${value.toFixed(2).replace(".", ",")}%`;
}

/**
 * O MySQL devolve DATETIME como "AAAA-MM-DD HH:MM:SS", que o Safari e o CEF
 * não aceitam direto no `new Date`. Também cobrimos ISO e epoch, porque cada
 * callback do servidor monta a data de um jeito.
 */
function parseDate(value: unknown): Date | null {
	if (value instanceof Date) return value;

	if (typeof value === "number") {
		const epoch = new Date(value < 1e12 ? value * 1000 : value);
		return Number.isNaN(epoch.getTime()) ? null : epoch;
	}

	if (typeof value !== "string" || !value) return null;

	const normalized = value.includes("T") ? value : value.replace(" ", "T");
	const parsed = new Date(normalized);

	return Number.isNaN(parsed.getTime()) ? null : parsed;
}

export function formatDateTime(value: unknown): { date: string; time: string } {
	const parsed = parseDate(value);

	if (!parsed) return { date: "--/--/----", time: "--:--" };

	return {
		date: parsed.toLocaleDateString("pt-BR"),
		time: parsed.toLocaleTimeString("pt-BR", {
			hour: "2-digit",
			minute: "2-digit",
		}),
	};
}
