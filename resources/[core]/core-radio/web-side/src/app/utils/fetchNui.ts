import { isEnvBrowser } from "./misc";

type NuiMessageData = Record<string, unknown>;

declare global {
	interface Window {
		GetParentResourceName: () => string;
	}
}

const getResourceName = (): string => {
	if (isEnvBrowser()) {
		return "browser:mode";
	}
	if (typeof window.GetParentResourceName !== "function") {
		throw new Error("GetParentResourceName is not available");
	}
	return window.GetParentResourceName();
};

export async function fetchNui<TResponse>(
	eventName: string,
	data?: NuiMessageData,
): Promise<TResponse | void> {
	if (isEnvBrowser()) {
		return;
	}

	const resourceName = getResourceName();
	const endpoint = `https://${resourceName}/${eventName}`;

	try {
		const response = await fetch(endpoint, {
			method: "POST",
			headers: { "Content-Type": "application/json; charset=UTF-8" },
			body: JSON.stringify(data ?? {}),
		});

		if (!response.ok) {
			return;
		}

		return (await response.json()) as TResponse;
	} catch {
		return;
	}
}
