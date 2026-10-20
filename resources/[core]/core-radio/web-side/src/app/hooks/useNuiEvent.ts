import { useEffect } from "react";

type NuiEventHandler<T> = (payload: T) => void;

interface NuiMessage<TPayload> {
	action: string;
	data: TPayload;
}

export function useNuiEvent<TPayload>(
	action: string,
	handler: NuiEventHandler<TPayload>,
) {
	useEffect(() => {
		const listener = (event: MessageEvent<NuiMessage<TPayload>>) => {
			if (event.data.action !== action) {
				return;
			}

			handler(event.data.data);
		};

		window.addEventListener("message", listener);
		return () => window.removeEventListener("message", listener);
	}, [action, handler]);
}
