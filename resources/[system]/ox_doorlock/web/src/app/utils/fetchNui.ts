import { isEnvBrowser, sleep } from "./misc";

const resourceName = (window as any).GetParentResourceName
	? (window as any).GetParentResourceName()
	: "ox_doorlock";

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

	isBrowser &&
		console.debug(`[DEBUG] Fetching ${path} with payload:`, payload, mockData);

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
	} catch (error) {
		console.error(
			`[ ERROR ] On Nui Callback ${path} -> `,
			JSON.stringify(error),
		);
		return null as CallbackResultType;
	}
}

export async function fetchNuiSimple<T = any>(
	eventName: string,
	data?: any,
): Promise<T> {
	const options = {
		method: "post",
		headers: {
			"Content-Type": "application/json; charset=UTF-8",
		},
		body: JSON.stringify(data),
	};

	const resName = (window as any).GetParentResourceName
		? (window as any).GetParentResourceName()
		: "ox_doorlock";

	const resp = await fetch(`https://${resName}/${eventName}`, options);
	return await resp.json();
}
