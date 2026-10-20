import { isEnvBrowser, sleep } from "./misc";

const resourceName = (window as any).GetParentResourceName
	? (window as any).GetParentResourceName()
	: "core-customization";

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

	if (isBrowser) {
		delay && (await sleep(delay));
		return mockData as CallbackResultType;
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

/**
 * O resource expõe um callback só, com o nome dele, e despacha pela chave
 * `action` — mesmo contrato dos demais resources Core.
 */
export async function nuiAction<T = any>(
	action: string,
	data?: Record<string, any>,
	mockData?: T,
): Promise<T> {
	return fetchNui<T>({
		path: resourceName,
		payload: { action, ...(data || {}) },
		mockData,
	});
}

/** Dispara sem esperar resposta, para ações que não devolvem nada. */
export function postNui(action: string, data?: Record<string, any>): void {
	void nuiAction(action, data).catch(() => {});
}
