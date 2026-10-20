export const isEnvBrowser = (): boolean => !(window as any).invokeNative;

export const sleep = (delay: number) =>
	new Promise((resolve) => {
		setTimeout(() => resolve(true), delay);
	});

/** Formata valores monetarios no padrao usado no jogo (R$ 14.300). */
export const formatMoney = (value: number): string =>
	new Intl.NumberFormat("pt-BR", {
		style: "currency",
		currency: "BRL",
		minimumFractionDigits: 0,
		maximumFractionDigits: 0,
	}).format(Number.isFinite(value) ? value : 0);

export const clamp = (value: number, min: number, max: number): number =>
	Math.min(Math.max(value, min), max);
