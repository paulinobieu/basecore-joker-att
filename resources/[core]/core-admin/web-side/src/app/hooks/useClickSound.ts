import ClickSound from "@views/assets/sounds/click.mp3";
import { useEffect } from "react";
import { useSound } from "./useSound";

export const useClickSound = () => {
	const { play } = useSound(ClickSound, { volume: 0.075 });

	useEffect(() => {
		const listener = (event: MouseEvent) => {
			// @ts-expect-error
			if (event.target.nodeName !== "BUTTON" || event.target.classList.contains("cursor-not-allowed"))
				return;
			play();
		};

		window.addEventListener("mousedown", listener);
		return () => window.removeEventListener("mousedown", listener);
	}, []);
};
