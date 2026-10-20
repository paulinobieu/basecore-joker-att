export function formatCurrency(
	value: number,
	prefix = "R$ ",
	suffix = "",
	separator = ".",
): string {
	const formatted = Math.floor(value)
		.toString()
		.replace(/\B(?=(\d{3})+(?!\d))/g, separator);

	return `${prefix}${formatted}${suffix}`;
}

export function formatTotemName(totemId: string): string {
	return totemId.replace(/[-_]/g, " ").trim() || "Autoatendimento";
}
