import { cn } from "@app/utils";
import type { CSSProperties, ReactNode } from "react";

interface PanelProps {
  title?: ReactNode;
  action?: ReactNode;
  className?: string;
  /** Usado apenas para proporcoes de layout (flex-grow), nao para estilo. */
  style?: CSSProperties;
  bodyClassName?: string;
  children: ReactNode;
}

export function Panel({
  title,
  action,
  className,
  style,
  bodyClassName,
  children,
}: PanelProps) {
  return (
    <section
      style={style}
      className={cn(
        "surface-panel flex flex-col overflow-hidden rounded-[.3125rem] border border-white/[.04] border-solid",
        className
      )}
    >
      {(title || action) && (
        <header className="flex h-[2.375rem] flex-shrink-0 items-center justify-between border-white/[.05] border-b border-solid px-[.875rem]">
          <h2 className="font-black text-[.75rem] text-[#EDEAE5B2] uppercase">
            {title}
          </h2>
          {action}
        </header>
      )}
      <div className={cn("flex-1 overflow-hidden", bodyClassName)}>
        {children}
      </div>
    </section>
  );
}
