import { isEnvBrowser, sleep } from "./misc";

const resourceName = (window as any).GetParentResourceName
	? (window as any).GetParentResourceName()
	: "zs-boilerplate";

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

	if (isBrowser && mockData) {
		delay && (await sleep(delay));
		return mockData;
	}

	try {
		const resp = await fetch(`https://${resourceName}/${path}`, {
			method: "post",
			headers: {
				"Content-Type": "application/json; charset=UTF-8",
			},
			body: JSON.stringify(payload),
		});
		const respFormatted = await resp.json();
		return respFormatted;
	} catch {
		return null as CallbackResultType;
	}
}
