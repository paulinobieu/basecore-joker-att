import { useEffect, useRef, type MutableRefObject } from "react";

type NuiHandlerSignature<T> = (data: T) => void;

export const useNuiMessage = <T = any>(
  action: string,
  handler: (payload: T) => void
) => {
  const savedHandler: MutableRefObject<NuiHandlerSignature<T>> = useRef(
    () => {}
  );

  useEffect(() => {
    savedHandler.current = handler;
  }, [handler]);

  useEffect(() => {
    const eventListener = (event: MessageEvent<{ action: string } & T>) => {
      const eventData = event.data;
      if (savedHandler.current && eventData?.action === action) {
        savedHandler.current(eventData as T);
      }
    };
    window.addEventListener("message", eventListener);
    return () => window.removeEventListener("message", eventListener);
  }, [action]);
};
