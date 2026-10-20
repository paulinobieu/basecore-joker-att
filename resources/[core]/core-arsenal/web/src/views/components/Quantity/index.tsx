import { cn } from "@app/utils";
import { IconMinus, IconPlus } from "@tabler/icons-react";

interface QuantityProps {
	value: number;
	max?: number;
	className?: string;
	onChange(value: number): void;
}

/** Passo de quantidade usado nas linhas da requisicao. */
export function Quantity({ value, max, className, onChange }: QuantityProps) {
	const canIncrease = max === undefined || value < max;

	return (
		<div
			className={cn(
				"filter-bar flex h-[1.5rem] items-center gap-1 rounded-[.1875rem] border border-white/[.06] border-solid px-1",
				className,
			)}
		>
			<button
				type="button"
				title="Diminuir"
				className="flex size-[1rem] items-center justify-center rounded-[.125rem] text-white/50 transition-all duration-300 hover:bg-white/10 hover:text-white"
				onClick={() => onChange(value - 1)}
			>
				<IconMinus stroke={3} className="size-[.625rem]" />
			</button>

			<span className="min-w-[1.25rem] text-center font-black text-[.6875rem] text-white tabular-nums">
				{value}
			</span>

			<button
				type="button"
				title="Aumentar"
				disabled={!canIncrease}
				className={cn(
					"flex size-[1rem] items-center justify-center rounded-[.125rem] transition-all duration-300",
					canIncrease
						? "text-white/50 hover:bg-white/10 hover:text-white"
						: "cursor-not-allowed text-white/15",
				)}
				onClick={() => canIncrease && onChange(value + 1)}
			>
				<IconPlus stroke={3} className="size-[.625rem]" />
			</button>
		</div>
	);
}
