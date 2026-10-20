import { cn } from "@app/utils";
import type { ReactNode } from "react";

interface PanelProps {
	title: string;
	subtitle?: string;
	className?: string;
	children: ReactNode;
}

/**
 * Coluna de conteudo da bancada: cabecalho fixo e corpo que rola sozinho.
 */
export function Panel({ title, subtitle, className, children }: PanelProps) {
	return (
		<section className={cn("flex min-h-0 flex-col", className)}>
			<header className="flex h-[3.5rem] flex-shrink-0 flex-col justify-center border-white/[.05] border-b border-solid px-[1rem]">
				<h2 className="truncate font-black text-[#EDEAE5] text-[.8125rem] uppercase">
					{title}
				</h2>
				{subtitle && (
					<span className="truncate font-semibold text-[.625rem] text-white/30">
						{subtitle}
					</span>
				)}
			</header>

			<div className="flex min-h-0 flex-1 flex-col">{children}</div>
		</section>
	);
}
