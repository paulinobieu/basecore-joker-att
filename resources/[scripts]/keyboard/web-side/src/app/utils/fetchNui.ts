import { isEnvBrowser } from "./misc";

const resourceName = (window as any).GetParentResourceName
	? (window as any).GetParentResourceName()
	: "keyboard";

export async function fetchNui<T = unknown>({
	path,
	payload,
	mockData,
}: {
	path: string;
	payload?: any;
	mockData?: T;
}): Promise<T> {
	const isBrowser = isEnvBrowser();

	if (isBrowser && mockData) {
		return mockData;
	}

	try {
		const resp = await fetch(`https://${resourceName}/${path}`, {
			method: "post",
			headers: { "Content-Type": "application/json; charset=UTF-8" },
			body: JSON.stringify(payload),
		});
		return await resp.json();
	} catch (error) {
		console.error(`[ERROR] fetchNui ${path} ->`, error);
		return null as T;
	}
}
