export const isEnvBrowser = (): boolean => !(window as any).invokeNative;

export const noop = () => {};

export const sleep = (delay: number) =>
	new Promise((resolve) => {
		setTimeout(() => {
			resolve(true);
		}, delay);
	});
