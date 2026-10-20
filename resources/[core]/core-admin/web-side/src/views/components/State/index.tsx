import { cn } from "@app/utils";
import { IconAlertTriangle } from "@tabler/icons-react";
import type { Icon } from "@tabler/icons-react";

export function Spinner({ className }: { className?: string }) {
  return (
    <span
      className={cn(
        "block size-[1.25rem] animate-spin rounded-full border-2 border-white/20 border-t-primaryColor",
        className
      )}
    />
  );
}

export function Loading({ label = "Carregando" }: { label?: string }) {
  return (
    <div className="flex h-full w-full flex-col items-center justify-center gap-3">
      <Spinner />
      <span className="font-black text-[.75rem] text-white/40 uppercase">
        {label}
      </span>
    </div>
  );
}

export function Empty({
  icon: EmptyIcon,
  label,
  hint,
}: {
  icon: Icon;
  label: string;
  hint?: string;
}) {
  return (
    <div className="flex h-full w-full flex-col items-center justify-center gap-2">
      <EmptyIcon stroke={1.5} className="size-[2.5rem] text-white/15" />
      <span className="font-black text-[.75rem] text-white/40 uppercase">
        {label}
      </span>
      {hint && (
        <span className="font-semibold text-[.6875rem] text-white/25">
          {hint}
        </span>
      )}
    </div>
  );
}

export function ErrorState({ message }: { message: string }) {
  return (
    <div className="flex h-full w-full flex-col items-center justify-center gap-2">
      <IconAlertTriangle stroke={1.5} className="size-[2.5rem] text-[#FF4B4B]" />
      <span className="font-black text-[.75rem] text-[#FF4B4B] uppercase">
        {message}
      </span>
    </div>
  );
}
