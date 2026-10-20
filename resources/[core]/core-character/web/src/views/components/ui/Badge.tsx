import { cn } from "@app/utils";
import type { HTMLAttributes } from "react";

/**
 * Mesmo gradiente do botao primario, sem hover — para rotulos que so
 * identificam a secao.
 */
export function Badge({ className, ...props }: HTMLAttributes<HTMLDivElement>) {
	return (
		<div
			className={cn(
				"inline-flex items-center gap-2 rounded-surface border border-white/[.15]",
				"bg-accent font-black text-white uppercase bg-blend-multiply",
				className,
			)}
			{...props}
		/>
	);
}
