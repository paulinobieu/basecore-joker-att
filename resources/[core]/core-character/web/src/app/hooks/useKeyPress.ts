import { useEffect } from "react";

/** Ignora teclas enquanto o jogador digita num campo de texto. */
export const isTyping = () => {
	const tag = document.activeElement?.tagName;

	return tag === "INPUT" || tag === "TEXTAREA";
};

export const useKeyPress = (
	key: string,
	handler: () => void,
	{ ignoreWhileTyping = true } = {},
) => {
	useEffect(() => {
		const listener = (event: KeyboardEvent) => {
			if (event.key !== key) return;
			if (ignoreWhileTyping && isTyping()) return;

			handler();
		};

		window.addEventListener("keydown", listener);

		return () => window.removeEventListener("keydown", listener);
	}, [handler, key, ignoreWhileTyping]);
};
