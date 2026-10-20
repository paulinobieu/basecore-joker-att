import { cn } from "@app/utils";
import type { ClassValue } from "clsx";
import type React from "react";
import { useEffect, useState } from "react";

const duration = 500;

const transitionStyle = (state: string) => ({
  opacity: state === "entered" ? 1 : 0,
  transition: `opacity ${duration}ms ease`,
});

interface AnimationProviderProps {
  children: React.ReactNode;
  show?: boolean;
  className?: ClassValue;
  onMouseEnter?(): void;
  onMouseLeave?(): void;
}

export const AnimationProvider: React.FC<AnimationProviderProps> = ({
  children,
  className,
  show = false,
  onMouseEnter,
  onMouseLeave,
}) => {
  const [status, setStatus] = useState("unmounted");

  useEffect(() => {
    if (!show) {
      setStatus("exiting");
      const timeoutId = setTimeout(() => setStatus("exited"), duration);
      return () => clearTimeout(timeoutId);
    }

    setStatus("entering");

    let frame = requestAnimationFrame(() => {
      frame = requestAnimationFrame(() => setStatus("entered"));
    });
    const timeoutId = setTimeout(() => setStatus("entered"), 32);

    return () => {
      cancelAnimationFrame(frame);
      clearTimeout(timeoutId);
    };
  }, [show]);

  useEffect(() => {
    if (status === "exited") {
      setStatus("unmounted");
    }
  }, [status]);

  if (status === "unmounted") {
    return null;
  }

  return (
    <div
      style={transitionStyle(status)}
      className={cn("overflow-visible", className)}
      onMouseEnter={onMouseEnter}
      onMouseLeave={onMouseLeave}
    >
      {children}
    </div>
  );
};
