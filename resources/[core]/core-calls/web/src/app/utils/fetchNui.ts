import { isEnvBrowser, sleep } from "./misc";

const resourceName = (window as any).GetParentResourceName
	? (window as any).GetParentResourceName()
	: "core-calls";

export async function fetchNui<CallbackResultType>({
	path,
	payload,
	delay,
	mockData,
}: {
	path: string;
	payload?: any;
	delay?: number;
	mockData?: CallbackResultType;
}): Promise<CallbackResultType> {
	const isBrowser = isEnvBrowser();

	if (isBrowser && mockData !== undefined) {
		if (delay) await sleep(delay);
		return mockData;
	}

	try {
		const resp = await fetch(`https://${resourceName}/${path}`, {
			method: "post",
			headers: { "Content-Type": "application/json; charset=UTF-8" },
			body: JSON.stringify(payload),
		});
		return await resp.json();
	} catch {
		return null as CallbackResultType;
	}
}

export function postNui(path: string, payload?: Record<string, any>): void {
	void fetchNui({ path, payload }).catch(() => {});
}
