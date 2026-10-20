export const isEnvBrowser = (): boolean =>
	!(window as Window & { invokeNative?: unknown }).invokeNative;

export const sleep = (delay: number) =>
	new Promise((resolve) => {
		setTimeout(resolve, delay);
	});
