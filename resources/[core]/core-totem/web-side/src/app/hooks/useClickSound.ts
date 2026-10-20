import { useEffect } from "react";
import clickSound from "../../assets/sounds/click.mp3";
import { useSound } from "./useSound";

export function useClickSound() {
	const { play } = useSound(clickSound);

	useEffect(() => {
		const listener = (event: MouseEvent) => {
			const button = (event.target as HTMLElement).closest("button");
			if (!button || button.disabled) return;
			play();
		};

		window.addEventListener("mousedown", listener);
		return () => window.removeEventListener("mousedown", listener);
	}, [play]);
}
