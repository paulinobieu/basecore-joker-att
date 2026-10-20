import { isEnvBrowser } from "./misc";

interface DebugEvent<T = unknown> {
	action: string;
	payload: T;
}

export const debugData = <P>(events: DebugEvent<P>[], timer = 1000): void => {
	if (import.meta.env.MODE === "development" && isEnvBrowser()) {
		for (const event of events) {
			setTimeout(() => {
				window.dispatchEvent(
					new MessageEvent("message", {
						data: { Action: event.action, Payload: event.payload },
					}),
				);
			}, timer);
		}
	}
};
