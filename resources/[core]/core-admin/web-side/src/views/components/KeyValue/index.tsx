import { cn } from "@app/utils";
import type { Icon } from "@tabler/icons-react";
import type { ReactNode } from "react";

interface KeyValueProps {
  label: string;
  icon?: Icon;
  className?: string;
  children: ReactNode;
}

/** Par rotulo/valor usado nas fichas de detalhe. */
export function KeyValue({
  label,
  icon: ItemIcon,
  className,
  children,
}: KeyValueProps) {
  return (
    <div
      className={cn(
        "flex items-center justify-between gap-2 border-white/[.04] border-b border-solid py-[.4375rem] last:border-0",
        className
      )}
    >
      <div className="flex min-w-0 items-center gap-1.5">
        {ItemIcon && (
          <ItemIcon
            stroke={2}
            className="size-[.8125rem] flex-shrink-0 text-white/25"
          />
        )}
        <span className="truncate font-black text-[.625rem] text-white/35 uppercase">
          {label}
        </span>
      </div>
      <span className="truncate font-black text-[.75rem] text-white">
        {children}
      </span>
    </div>
  );
}
