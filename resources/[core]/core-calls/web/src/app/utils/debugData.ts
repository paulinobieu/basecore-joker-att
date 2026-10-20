import { isEnvBrowser } from "./misc";

interface DebugEvent<T = unknown> {
	action: string;
	payload?: T;
}

/**
 * Dispara eventos como se viessem do Lua (SendNUIMessage). So roda em dev
 * dentro do navegador — em produção o overlay e silencioso.
 */
export const debugData = <P>(events: DebugEvent<P>[], timer = 200): void => {
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
