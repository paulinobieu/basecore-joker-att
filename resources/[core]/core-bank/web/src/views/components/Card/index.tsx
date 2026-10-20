import type { Icon } from "@tabler/icons-react";
import { cn } from "@app/utils";
import type { ReactNode } from "react";

interface CardProps {
	title: string;
	icon: Icon;
	action?: ReactNode;
	className?: string;
	bodyClassName?: string;
	children: ReactNode;
}

/**
 * Bloco padrão das telas: cabeçalho discreto com ícone, ação opcional à
 * direita e o conteúdo ocupando o resto da altura.
 */
export function Card({
	title,
	icon: CardIcon,
	action,
	className,
	bodyClassName,
	children,
}: CardProps) {
	return (
		<section
			className={cn(
				"surface-panel flex min-h-0 flex-col rounded-[.3125rem] border border-white/[.05] border-solid p-[1rem]",
				className,
			)}
		>
			<header className="flex min-h-[1.75rem] flex-shrink-0 items-center justify-between gap-[.75rem]">
				<div className="flex min-w-0 items-center gap-[.5rem]">
					<CardIcon
						stroke={2.5}
						className="size-[.875rem] flex-shrink-0 text-primaryColor"
					/>
					<h2 className="truncate font-black text-[.75rem] text-ink-faint uppercase tracking-wide">
						{title}
					</h2>
				</div>

				{action && (
					<div className="flex flex-shrink-0 items-center">{action}</div>
				)}
			</header>

			<div
				className={cn(
					"mt-[.75rem] flex min-h-0 flex-1 flex-col",
					bodyClassName,
				)}
			>
				{children}
			</div>
		</section>
	);
}
