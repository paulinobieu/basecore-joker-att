import { cn } from "@app/utils";
import { IconChevronLeft, IconChevronRight } from "@tabler/icons-react";
import { useMemo } from "react";

interface PaginationProps {
  page: number;
  totalPages: number;
  summary?: string;
  onChange: (page: number) => void;
}

export function Pagination({
  page,
  totalPages,
  summary,
  onChange,
}: PaginationProps) {
  const pages = useMemo(() => {
    const all = Array.from({ length: totalPages }, (_, index) => index + 1);
    const visible = all.filter((value) =>
      totalPages <= 7
        ? true
        : value === 1 || value === totalPages || Math.abs(value - page) <= 1
    );

    return visible.reduce<(number | "…")[]>((acc, value) => {
      const last = acc[acc.length - 1];
      if (typeof last === "number" && value - last > 1) acc.push("…");
      acc.push(value);
      return acc;
    }, []);
  }, [page, totalPages]);

  const step = cn(
    "flex size-[1.875rem] items-center justify-center rounded-[.25rem] border border-white/[.05] border-solid transition-all duration-300"
  );

  return (
    <div className="flex h-[1.875rem] flex-shrink-0 items-center justify-between">
      <span className="font-extrabold text-[.6875rem] text-white/35 uppercase">
        {summary}
      </span>

      <div className="flex items-center gap-1.5">
        <button
          type="button"
          disabled={page <= 1}
          onClick={() => onChange(Math.max(1, page - 1))}
          className={cn(step, "ghost-btn")}
        >
          <IconChevronLeft stroke={2} className="size-[.875rem] text-white" />
        </button>

        {pages.map((value, index) =>
          value === "…" ? (
            <span
              key={`gap-${index}`}
              className="px-1 font-black text-[.6875rem] text-white/30"
            >
              …
            </span>
          ) : (
            <button
              key={value}
              type="button"
              onClick={() => onChange(value)}
              className={cn(
                step,
                "ghost-btn font-black text-[.6875rem]",
                value === page ? "is-active text-white" : "text-white/50"
              )}
            >
              <span className="relative z-10">{value}</span>
            </button>
          )
        )}

        <button
          type="button"
          disabled={page >= totalPages}
          onClick={() => onChange(Math.min(totalPages, page + 1))}
          className={cn(step, "ghost-btn")}
        >
          <IconChevronRight stroke={2} className="size-[.875rem] text-white" />
        </button>
      </div>
    </div>
  );
}
