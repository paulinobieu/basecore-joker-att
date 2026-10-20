import { cn } from "@app/utils";
import type { HTMLAttributes } from "react";

/** Chip do valor numerico exibido acima do slider. */
export function Chip({ className, ...props }: HTMLAttributes<HTMLSpanElement>) {
	return (
		<span
			className={cn(
				"inline-flex items-center justify-center rounded-field border border-white/[.06]",
				"bg-black/[.35] px-2 py-[.15rem] font-black text-[.6875rem] text-ink tabular-nums",
				className,
			)}
			{...props}
		/>
	);
}
