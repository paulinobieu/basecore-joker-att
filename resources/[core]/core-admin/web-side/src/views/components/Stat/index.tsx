import { cn } from "@app/utils";
import type { Icon } from "@tabler/icons-react";
import { Card } from "@views/components/Card";
import { Meter } from "@views/components/Meter";
import type { ReactNode } from "react";

interface StatProps {
  label: string;
  value: ReactNode;
  icon: Icon;
  suffix?: ReactNode;
  hint?: ReactNode;
  meter?: { value: number; max?: number; color?: string };
  className?: string;
}

/** Bloco de metrica compacto usado nas faixas de resumo das paginas. */
export function Stat({
  label,
  value,
  icon: StatIcon,
  suffix,
  hint,
  meter,
  className,
}: StatProps) {
  return (
    <Card className={cn("justify-between p-[.875rem]", className)}>
      <div className="flex items-center justify-between gap-2">
        <span className="truncate font-black text-[.625rem] text-white/40 uppercase">
          {label}
        </span>
        <StatIcon
          stroke={2}
          className="size-[1rem] flex-shrink-0 text-primaryColor"
        />
      </div>

      <div className="mt-1.5 flex items-baseline gap-1.5">
        <span className="font-black text-[1.375rem] text-white leading-none">
          {value}
        </span>
        {suffix && (
          <span className="font-black text-[.75rem] text-white/30 leading-none">
            {suffix}
          </span>
        )}
      </div>

      {meter ? (
        <Meter
          className="mt-auto pt-2"
          value={meter.value}
          max={meter.max}
          color={meter.color}
        />
      ) : (
        hint && (
          <span className="mt-auto truncate pt-2 font-semibold text-[.625rem] text-white/25">
            {hint}
          </span>
        )
      )}
    </Card>
  );
}
