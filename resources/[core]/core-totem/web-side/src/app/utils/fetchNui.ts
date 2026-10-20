import { isEnvBrowser } from "./misc";

const resourceName =
	(
		window as Window & { GetParentResourceName?: () => string }
	).GetParentResourceName?.() ?? "core-totem";

export async function fetchNui<Response = unknown>({
	path,
	payload = {},
	mockData,
}: {
	path: string;
	payload?: Record<string, unknown>;
	mockData?: Response;
}): Promise<Response> {
	if (isEnvBrowser()) {
		return mockData as Response;
	}

	try {
		const response = await fetch(`https://${resourceName}/${path}`, {
			method: "POST",
			headers: { "Content-Type": "application/json; charset=UTF-8" },
			body: JSON.stringify(payload),
		});

		return (await response.json()) as Response;
	} catch (error) {
		console.error(`[core-totem] NUI callback ${path} failed`, error);
		return null as Response;
	}
}
