import { type MutableRefObject, useEffect, useRef } from "react";

type NuiHandlerSignature<T> = (data: T) => void;

/**
 * Hook to listen NUI messages from the Lua client.
 * This resource uses capital-case keys: Action / Payload
 */
export const useNuiMessage = <T = never>(
	action: string,
	handler: (payload: T) => void,
) => {
	const savedHandler: MutableRefObject<NuiHandlerSignature<T>> = useRef(
		() => {},
	);

	useEffect(() => {
		savedHandler.current = handler;
	}, [handler]);

	useEffect(() => {
		const eventListener = (event: MessageEvent) => {
			const { Action: eventAction, Payload: payload } = event.data ?? {};
			if (savedHandler.current && eventAction === action) {
				savedHandler.current(payload as T);
			}
		};
		window.addEventListener("message", eventListener);
		return () => window.removeEventListener("message", eventListener);
	}, [action]);
};
