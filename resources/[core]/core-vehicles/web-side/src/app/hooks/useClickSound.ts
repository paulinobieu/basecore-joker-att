import { useEffect } from "react";
import { useSound } from "./useSound";

export const useClickSound = () => {
  const { play } = useSound("sounds/click.mp3", { volume: 0.075 });

  useEffect(() => {
    const listener = (event: MouseEvent) => {
      const target = event.target as HTMLElement;
      const style = window.getComputedStyle(target);
      if (style.cursor === "pointer") {
        play();
      }
    };
    window.addEventListener("mousedown", listener);
    return () => window.removeEventListener("mousedown", listener);
  }, [play]);
};
