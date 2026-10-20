import { cn } from "@app/utils";
import type { ReactNode } from "react";

interface MeterProps {
  label?: ReactNode;
  value: number;
  max?: number;
  color?: string;
  suffix?: string;
  className?: string;
}

export function Meter({
  label,
  value,
  max = 100,
  color = "rgb(var(--primaryColor))",
  suffix,
  className,
}: MeterProps) {
  const percent = max > 0 ? Math.max(0, Math.min(100, (value / max) * 100)) : 0;

  return (
    <div className={cn("flex w-full flex-col gap-1", className)}>
      {(label || suffix) && (
        <div className="flex items-center justify-between">
          {label && (
            <span className="font-black text-[.625rem] text-white/40 uppercase">
              {label}
            </span>
          )}
          {suffix && (
            <span className="font-black text-[.625rem] text-white">
              {suffix}
            </span>
          )}
        </div>
      )}
      <div className="h-[.25rem] w-full overflow-hidden rounded-full bg-white/[.06]">
        <div
          className="h-full rounded-full transition-all duration-500"
          style={{ width: `${percent}%`, backgroundColor: color }}
        />
      </div>
    </div>
  );
}
