import { useIsRendered } from "@app/hooks/useIsRendered";
import { AnimationProvider } from "@app/providers/Animation";
import { cn } from "@app/utils";
import type { ReactNode } from "react";

export function Page({
  children,
  className,
}: {
  children: ReactNode;
  className?: string;
}) {
  const { isRendered } = useIsRendered();

  return (
    <AnimationProvider
      show={isRendered}
      className={cn(
        "flex h-full w-full flex-col gap-[.9375rem] p-[1.25rem]",
        className
      )}
    >
      {children}
    </AnimationProvider>
  );
}
