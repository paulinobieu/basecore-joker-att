import { isEnvBrowser, sleep } from "./misc";

const resourceName = (window as any).GetParentResourceName
	? (window as any).GetParentResourceName()
	: "core-booster";

/**
 * Transporte com o Lua. No navegador devolve `mockData`, entao a tela pode ser
 * desenvolvida sem o jogo aberto.
 */
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

	if (isBrowser) {
		if (delay) await sleep(delay);
		return mockData as CallbackResultType;
	}

	try {
		const response = await fetch(`https://${resourceName}/${path}`, {
			method: "post",
			headers: {
				"Content-Type": "application/json; charset=UTF-8",
			},
			body: JSON.stringify(payload ?? {}),
		});

		return (await response.json()) as CallbackResultType;
	} catch (error) {
		console.error(`[ ERROR ] NUI callback ${path} -> `, error);
		return null as CallbackResultType;
	}
}
