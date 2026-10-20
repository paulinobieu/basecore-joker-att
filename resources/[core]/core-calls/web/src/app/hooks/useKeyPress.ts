import { useEffect } from "react";

export const useKeyPress = (key: string, handler: () => void) => {
	useEffect(() => {
		const listener = (event: KeyboardEvent) => {
			if (event.key === key) handler();
		};
		window.addEventListener("keydown", listener);
		return () => window.removeEventListener("keydown", listener);
	}, [key, handler]);
};
