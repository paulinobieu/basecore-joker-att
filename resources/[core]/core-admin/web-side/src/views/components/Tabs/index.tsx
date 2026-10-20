import { cn } from "@app/utils";

export interface TabItem {
  value: string;
  label: string;
  count?: number;
}

interface TabsProps {
  items: TabItem[];
  value: string;
  className?: string;
  /** `true` distribui os itens na largura total; `false` usa largura do texto. */
  fill?: boolean;
  onChange: (value: string) => void;
}

export function Tabs({
  items,
  value,
  className,
  fill = true,
  onChange,
}: TabsProps) {
  return (
    <div className={cn("flex flex-shrink-0 items-center gap-[.5rem]", className)}>
      {items.map((item) => (
        <button
          key={item.value}
          type="button"
          onClick={() => onChange(item.value)}
          className={cn(
            "ghost-btn relative flex h-[2.25rem] items-center justify-center gap-1.5 rounded-[.3125rem] border border-white/5 border-solid font-black text-[.75rem] uppercase transition-all duration-300",
            fill ? "flex-1" : "px-[.75rem]",
            item.value === value
              ? "is-active text-white"
              : "text-[#EDEAE599] hover:text-[#EDEAE5]"
          )}
        >
          <span className="relative z-10">{item.label}</span>
          {item.count !== undefined && (
            <span
              className={cn(
                "relative z-10 font-black text-[.625rem]",
                item.value === value ? "text-white/60" : "text-white/30"
              )}
            >
              {item.count}
            </span>
          )}
        </button>
      ))}
    </div>
  );
}
