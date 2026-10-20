import { useEffect, useRef } from "react";

export const useKeyPress = (code: string, handler: () => void, enabled = true) => {
  const savedHandler = useRef(handler);

  useEffect(() => {
    savedHandler.current = handler;
  }, [handler]);

  useEffect(() => {
    if (!enabled) return;

    const listener = (event: KeyboardEvent) => {
      if (event.code !== code) return;
      event.stopPropagation();
      savedHandler.current();
    };

    window.addEventListener("keydown", listener, true);
    return () => window.removeEventListener("keydown", listener, true);
  }, [code, enabled]);
};
