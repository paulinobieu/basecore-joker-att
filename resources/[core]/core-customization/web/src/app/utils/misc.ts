export const isEnvBrowser = (): boolean => !(window as any).invokeNative;

export const sleep = (delay: number) =>
	new Promise((resolve) => {
		setTimeout(() => {
			resolve(true);
		}, delay);
	});

export const clamp = (value: number, min: number, max: number) =>
	Math.max(min, Math.min(max, value));
