import { useEffect, useState, type CSSProperties, type ReactNode } from "react";

const duration = 300;

const transitionStyle = (entered: boolean): CSSProperties => ({
  opacity: entered ? 1 : 0,
  transition: `opacity ${duration}ms ease`,
});

interface AnimationProviderProps {
  children: ReactNode;
  show?: boolean;
}

export function AnimationProvider({
  children,
  show = false,
}: AnimationProviderProps) {
  const [rendered, setRendered] = useState(show);
  const [entered, setEntered] = useState(show);

  useEffect(() => {
    let animationFrame: number | undefined;
    let unmountTimer: number | undefined;

    if (show) {
      setRendered(true);
      animationFrame = requestAnimationFrame(() => setEntered(true));
    } else {
      setEntered(false);
      unmountTimer = window.setTimeout(() => setRendered(false), duration);
    }

    return () => {
      if (animationFrame !== undefined) cancelAnimationFrame(animationFrame);
      if (unmountTimer !== undefined) clearTimeout(unmountTimer);
    };
  }, [show]);

  if (!rendered) return null;

  return <div style={transitionStyle(entered)}>{children}</div>;
}
