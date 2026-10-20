import { lazy } from "react";

export const lazyLoad = <T extends Record<string, any>>(
	loader: (x?: string) => Promise<T>,
) =>
	new Proxy({} as unknown as T, {
		get: (_, componentName: string | symbol) => {
			if (typeof componentName === "string") {
				return lazy(() =>
					loader().then((module) => ({
						default: module[componentName] as any as React.ComponentType<any>,
					})),
				);
			}
		},
	});
