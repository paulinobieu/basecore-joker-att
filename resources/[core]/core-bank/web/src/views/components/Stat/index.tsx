import { currencySymbol, formatMoney } from "@app/utils/format";
import type { Icon } from "@tabler/icons-react";
import { cn } from "@app/utils";
import type { ReactNode } from "react";

interface StatProps {
	label: string;
	value: number;
	/** Prefixo do valor. `false` remove — serve para número que não é dinheiro. */
	symbol?: string | false;
	/** Sufixo colado no número, como "%". */
	suffix?: string;
	icon: Icon;
	footnote?: ReactNode;
	accent?: boolean;
	className?: string;
}

/** Número grande do topo das telas: saldo, investido, pendências. */
export function Stat({
	label,
	value,
	symbol,
	suffix,
	icon: StatIcon,
	footnote,
	accent,
	className,
}: StatProps) {
	return (
		<div
			className={cn(
				"surface-panel flex min-w-0 flex-col justify-between rounded-[.3125rem] border border-white/[.05] border-solid p-[1rem]",
				accent &&
					"border-primaryColor/40 shadow-[0_0_1.5rem_0_rgba(var(--primaryColor),0.12)]",
				className,
			)}
		>
			<div className="flex items-center gap-[.5rem]">
				<StatIcon
					stroke={2.5}
					className={cn(
						"size-[.875rem] flex-shrink-0",
						accent ? "text-primaryColor" : "text-white/25",
					)}
				/>
				<span className="truncate font-black text-[.6875rem] text-ink-ghost uppercase tracking-wide">
					{label}
				</span>
			</div>

			<div className="flex items-baseline gap-[.375rem]">
				{symbol !== false && (
					<span className="flex-shrink-0 font-black text-[1.125rem] text-white/25">
						{symbol ?? currencySymbol()}
					</span>
				)}
				<span className="truncate font-black text-[1.75rem] text-ink leading-none">
					{formatMoney(value)}
					{suffix}
				</span>
			</div>

			<div className="line-clamp-2 font-semibold text-[.6875rem] text-ink-ghost leading-tight">
				{footnote}
			</div>
		</div>
	);
}
