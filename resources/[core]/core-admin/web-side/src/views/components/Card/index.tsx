import { cn } from "@app/utils";
import { Detail } from "@views/components/Detail";
import { useState } from "react";
import type { ReactNode } from "react";

interface CardProps {
  active?: boolean;
  detail?: boolean;
  className?: string;
  children: ReactNode;
}

export function Card({
  active = false,
  detail = true,
  className,
  children,
}: CardProps) {
  const [isHovered, setIsHovered] = useState(false);

  return (
    <div
      className={cn(
        "surface-card flex flex-col rounded-[.3125rem] border border-white/[.03] border-solid",
        className
      )}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      {detail && <Detail active={isHovered || active} />}
      <div className={cn("accent-overlay", active && "is-active")} />
      <div className="relative z-30 flex h-full w-full flex-col">{children}</div>
    </div>
  );
}
