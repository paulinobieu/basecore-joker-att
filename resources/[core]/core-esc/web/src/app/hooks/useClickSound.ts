import ClickSound from "@views/assets/sounds/click.mp3";
import { useEffect } from "react";
import { useSound } from "./useSound";

export const useClickSound = () => {
	const { play } = useSound(ClickSound, { volume: 0.05 });

	// biome-ignore lint/correctness/useExhaustiveDependencies: <explanation>
	useEffect(() => {
		const listener = (event: MouseEvent) => {
			let target = event.target as HTMLElement | null;

			while (target) {
				if (target.nodeName === "BUTTON") {
					play();
					return;
				}
				target = target.parentElement;
			}
		};

		window.addEventListener("mousedown", listener);

		return () => {
			window.removeEventListener("mousedown", listener);
		};
	}, []);
};
