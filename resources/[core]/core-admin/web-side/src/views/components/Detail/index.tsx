import { cn } from "@app/utils";

interface DetailProps {
  active?: boolean;
  full?: boolean;
}

export function Detail({ active = false, full = false }: DetailProps) {
  const line = cn(
    "absolute bg-[#D9D9D9]/[.03] transition-all duration-500",
    active && "bg-[#D9D9D9]/[.13]"
  );
  const dot = cn(
    "absolute size-[.4375rem] rounded-full bg-[#303030] transition-all duration-500",
    active && "bg-primaryColor"
  );

  return (
    <div className="pointer-events-none absolute inset-0 z-[20] overflow-hidden rounded-[.3125rem]">
      <div className="relative h-full w-full">
        <div className={cn(line, "top-5 h-[.0625rem] w-full")} />
        <div className={cn(line, "left-5 h-full w-[.0625rem]")} />
        <div className={cn(line, "right-5 h-full w-[.0625rem]")} />
        {full && <div className={cn(line, "bottom-5 h-[.0625rem] w-full")} />}

        <div className={cn(dot, "top-[1.0625rem] left-[1.0625rem]")} />
        <div className={cn(dot, "top-[1.0625rem] right-[1.0625rem]")} />
        {full && (
          <>
            <div className={cn(dot, "bottom-[1.0625rem] left-[1.0625rem]")} />
            <div className={cn(dot, "right-[1.0625rem] bottom-[1.0625rem]")} />
          </>
        )}
      </div>
    </div>
  );
}
