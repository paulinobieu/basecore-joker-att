export const isEnvBrowser = (): boolean => !(window as any).invokeNative;

export const sleep = (delay: number) =>
	new Promise((resolve) => {
		setTimeout(() => {
			resolve(true);
		}, delay);
	});

export const formatNumber = (n: number): string => n.toLocaleString("pt-BR");

export const formatDateTime = (timestamp: number): string => {
	const date = new Date(timestamp);
	const day = String(date.getDate()).padStart(2, "0");
	const month = String(date.getMonth() + 1).padStart(2, "0");
	const year = date.getFullYear();
	const hours = String(date.getHours()).padStart(2, "0");
	const minutes = String(date.getMinutes()).padStart(2, "0");
	return `${day}/${month}/${year} - ${hours}:${minutes}`;
};
