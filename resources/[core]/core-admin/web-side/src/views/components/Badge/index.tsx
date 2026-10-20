import { cn } from "@app/utils";
import type { ReactNode } from "react";

interface BadgeProps {
  color?: string;
  dot?: boolean;
  className?: string;
  children: ReactNode;
}

export function Badge({
  color = "#EDEAE5",
  dot = false,
  className,
  children,
}: BadgeProps) {
  return (
    <span
      className={cn(
        "inline-flex h-[1.625rem] items-center gap-1.5 rounded-[.25rem] border border-white/[.05] border-solid px-2 font-black text-[.6875rem] uppercase",
        className
      )}
      style={{ backgroundColor: `${color}14`, color }}
    >
      {dot && (
        <span
          className="size-[.375rem] rounded-full"
          style={{ backgroundColor: color }}
        />
      )}
      {children}
    </span>
  );
}

export function StatusBadge({ online }: { online: boolean }) {
  return (
    <Badge color={online ? "#9CF35B" : "#FF4B4B"} dot>
      {online ? "Online" : "Offline"}
    </Badge>
  );
}
