import { useEffect } from "react";

export const useKeyPress = (key: string, handler: () => void) => {
	useEffect(() => {
		const listener = (event: KeyboardEvent) => {
			if (event.key !== key) return;

			const spinning = document.querySelector("[data-spinning]");
			if (spinning) return;

			const modalOpen = document.querySelector("[data-modal-open]");
			if (modalOpen) return;

			handler();
		};
		window.addEventListener("keydown", listener);

		return () => window.removeEventListener("keydown", listener);
	}, [handler, key]);
};
