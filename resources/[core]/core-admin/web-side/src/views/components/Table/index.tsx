import { cn } from "@app/utils";
import type { ReactNode } from "react";

export type Column = ReactNode | { label: ReactNode; className?: string };

function columnLabel(column: Column) {
  return column && typeof column === "object" && "label" in column
    ? column.label
    : (column as ReactNode);
}

function columnClass(column: Column) {
  return column && typeof column === "object" && "className" in column
    ? column.className
    : undefined;
}

export function Table({
  columns,
  className,
  children,
}: {
  columns: Column[];
  className?: string;
  children: ReactNode;
}) {
  return (
    <div
      className={cn(
        "surface-panel flex h-full flex-col overflow-hidden rounded-[.3125rem] border border-white/[.04] border-solid",
        className
      )}
    >
      <div className="flex h-[2.375rem] flex-shrink-0 items-center border-white/[.05] border-b border-solid px-[.875rem]">
        {columns.map((column, index) => (
          <div
            key={index}
            className={cn(
              "flex-1 pr-2 font-black text-[.6875rem] text-[#EDEAE559] uppercase",
              columnClass(column)
            )}
          >
            {columnLabel(column)}
          </div>
        ))}
      </div>
      <div className="customScrollbar flex-1 overflow-y-auto">{children}</div>
    </div>
  );
}

export function Row({
  onClick,
  className,
  children,
}: {
  onClick?: () => void;
  className?: string;
  children: ReactNode;
}) {
  return (
    <div
      onClick={onClick}
      className={cn(
        "table-row-bar flex min-h-[3.125rem] items-center border-white/[.03] border-b border-solid px-[.875rem]",
        onClick && "cursor-pointer",
        className
      )}
    >
      {children}
    </div>
  );
}

export function Cell({
  className,
  children,
}: {
  className?: string;
  children: ReactNode;
}) {
  return (
    <div
      className={cn(
        "flex flex-1 items-center gap-2 pr-2 font-bold text-[.8125rem] text-[#EDEAE5]",
        className
      )}
    >
      {children}
    </div>
  );
}

/** Celula com valor principal + linha de apoio (identidade compacta). */
export function CellStack({
  title,
  subtitle,
  className,
}: {
  title: ReactNode;
  subtitle?: ReactNode;
  className?: string;
}) {
  return (
    <div className={cn("flex min-w-0 flex-col", className)}>
      <span className="truncate font-black text-[.8125rem] text-[#EDEAE5]">
        {title}
      </span>
      {subtitle && (
        <span className="truncate font-semibold text-[.625rem] text-white/30">
          {subtitle}
        </span>
      )}
    </div>
  );
}
