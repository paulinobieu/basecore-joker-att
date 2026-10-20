import { cn } from "@app/utils";

interface AvatarProps {
  name?: string;
  online?: boolean;
  className?: string;
}

/**
 * Iniciais em placa com acento -- mesmo tratamento ja usado no chat staff.
 */
export function Avatar({ name, online, className }: AvatarProps) {
  const initials = (name || "?")
    .split(" ")
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part.charAt(0).toUpperCase())
    .join("");

  return (
    <div className="relative flex-shrink-0">
      <div
        className={cn(
          "accent-btn flex size-[2rem] items-center justify-center rounded-[.3125rem] font-black text-[.6875rem] text-white",
          className
        )}
      >
        <span className="relative z-10">{initials || "?"}</span>
      </div>
      {online !== undefined && (
        <span
          className="-right-[.125rem] -bottom-[.125rem] absolute size-[.5rem] rounded-full border-[.09375rem] border-[#111114] border-solid"
          style={{ backgroundColor: online ? "#9CF35B" : "#FF4B4B" }}
        />
      )}
    </div>
  );
}
