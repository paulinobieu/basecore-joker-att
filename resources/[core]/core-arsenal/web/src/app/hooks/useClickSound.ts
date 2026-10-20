import ClickSound from "@views/assets/sounds/click.mp3";
import { useEffect } from "react";
import { useSound } from "./useSound";

export const useClickSound = () => {
	const { play } = useSound(ClickSound, { volume: 0.075 });

	useEffect(() => {
		const listener = (event: MouseEvent) => {
			const target = event.target as HTMLElement | null;
			if (!target) return;

			const button = target.closest("button");
			if (!button || button.disabled) return;

			play();
		};

		window.addEventListener("mousedown", listener);

		return () => window.removeEventListener("mousedown", listener);
	}, [play]);
};
