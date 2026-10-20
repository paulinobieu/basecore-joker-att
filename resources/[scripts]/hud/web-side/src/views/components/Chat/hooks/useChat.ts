import { useChatStore } from "@app/stores/Chat";
import { useEffect } from "react";

export function useChatTimeout() {
	const { chatTimeout, setChatTimeout, isInputVisible, setIsChatVisible } =
		useChatStore();

	// biome-ignore lint/correctness/useExhaustiveDependencies: <explanation>
	useEffect(() => {
		if (chatTimeout <= 0) {
			if (isInputVisible) return;
			return setIsChatVisible(false);
		}

		const interval = setInterval(() => {
			setChatTimeout(chatTimeout - 1);
		}, 1000);

		return () => clearInterval(interval);
	}, [chatTimeout, isInputVisible]);
}

export function useChatKeyboardEvents() {
	const {
		handleEscape,
		handleSendMessage,
		navigateHistory,
		isInputVisible,
		isChatVisible,
		text,
	} = useChatStore();

	// biome-ignore lint/correctness/useExhaustiveDependencies: <explanation>
	useEffect(() => {
		const keyHandler = (event: KeyboardEvent): void => {
			const keyHandlers: Record<string, () => void> = {
				Escape: handleEscape,
				Enter: handleSendMessage,
				ArrowUp: () => navigateHistory("up"),
				ArrowDown: () => navigateHistory("down"),
			};

			keyHandlers[event.code]?.();
		};

		window.addEventListener("keydown", keyHandler);
		return () => {
			window.removeEventListener("keydown", keyHandler);
		};
	}, [isInputVisible, isChatVisible, text]);
}
