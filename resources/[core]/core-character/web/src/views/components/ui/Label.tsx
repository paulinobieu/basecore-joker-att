import { cn } from "@app/utils";
import type { HTMLAttributes } from "react";

/**
 * Faixa de rotulo a esquerda dos cards de slider/cor. Acende junto com
 * o painel: o `group-hover` vem do <Panel interactive>.
 */
export function Label({ className, ...props }: HTMLAttributes<HTMLDivElement>) {
	return (
		<div
			className={cn(
				"font-black text-ink-muted uppercase tracking-[.08em] transition-colors duration-500",
				"group-hover:text-ink",
				className,
			)}
			{...props}
		/>
	);
}
