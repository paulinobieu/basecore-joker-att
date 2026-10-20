import { isEnvBrowser } from "./misc";

interface DebugEvent<T = unknown> {
	action: string;
	payload: T;
}

/**
 * Emula o SendNUIMessage do Lua enquanto a tela roda no navegador.
 */
export const debugData = <P>(events: DebugEvent<P>[], timer = 300): void => {
	if (import.meta.env.MODE === "development" && isEnvBrowser()) {
		for (const event of events) {
			setTimeout(() => {
				window.dispatchEvent(
					new MessageEvent("message", {
						data: { action: event.action, payload: event.payload },
					}),
				);
			}, timer);
		}
	}
};
