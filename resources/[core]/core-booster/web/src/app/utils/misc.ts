export const isEnvBrowser = (): boolean => !(window as any).invokeNative;

export const sleep = (delay: number) =>
	new Promise((resolve) => {
		setTimeout(() => resolve(true), delay);
	});

/** Separa milhar no padrao pt-BR (55.000). */
export const formatNumber = (value: number): string =>
	new Intl.NumberFormat("pt-BR").format(
		Number.isFinite(value) ? Math.trunc(value) : 0,
	);

/**
 * Lista vazia no Lua chega como objeto no JSON, entao toda colecao vinda do
 * servidor passa por aqui antes de ser percorrida.
 */
export const toArray = <T>(value: T[] | undefined | null): T[] =>
	Array.isArray(value) ? value : [];

/** Substitui os %s do idioma na ordem em que aparecem. */
export const format = (text: string, ...values: (string | number)[]): string => {
	let index = 0;

	return text.replace(/%s/g, () => {
		const value = values[index];
		index += 1;

		return value === undefined ? "" : String(value);
	});
};
