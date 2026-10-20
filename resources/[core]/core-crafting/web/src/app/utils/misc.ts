export const isEnvBrowser = (): boolean => !(window as any).invokeNative;

export const sleep = (delay: number) =>
	new Promise((resolve) => {
		setTimeout(() => resolve(true), delay);
	});

export const clamp = (value: number, min: number, max: number): number =>
	Math.min(Math.max(value, min), max);

/** Separa milhar no padrao pt-BR (48.000). */
export const formatNumber = (value: number): string =>
	new Intl.NumberFormat("pt-BR").format(
		Number.isFinite(value) ? Math.trunc(value) : 0,
	);

/** Duracao curta para tempos de fabricacao (45s, 2m 30s, 1h 05m). */
export const formatTime = (seconds: number): string => {
	const total = Math.max(0, Math.ceil(seconds));

	if (total < 60) return `${total}s`;

	const minutes = Math.floor(total / 60);
	const rest = total % 60;

	if (minutes < 60) return rest > 0 ? `${minutes}m ${rest}s` : `${minutes}m`;

	const hours = Math.floor(minutes / 60);
	const restMinutes = minutes % 60;

	return `${hours}h ${String(restMinutes).padStart(2, "0")}m`;
};
