import { cn } from "@app/utils";
import { IconMinus, IconPlus } from "@tabler/icons-react";

interface QuantityProps {
	value: number;
	max: number;
	onChange(value: number): void;
}

/**
 * Passo de quantidade da fabricacao.
 */
export function Quantity({ value, max, onChange }: QuantityProps) {
	const canDecrease = value > 1;
	const canIncrease = value < max;

	const step = cn(
		"flex size-[1.75rem] items-center justify-center rounded-[.25rem] transition-all duration-300",
	);

	return (
		<div className="filter-bar flex h-[2.625rem] flex-shrink-0 items-center gap-2 rounded-[.3125rem] border border-white/[.08] border-solid px-2">
			<button
				type="button"
				title="Diminuir"
				disabled={!canDecrease}
				onClick={() => onChange(value - 1)}
				className={cn(
					step,
					canDecrease
						? "text-white/50 hover:bg-white/10 hover:text-white"
						: "cursor-not-allowed text-white/15",
				)}
			>
				<IconMinus stroke={3} className="size-[.875rem]" />
			</button>

			<span className="min-w-[2rem] text-center font-black text-[.9375rem] text-white">
				{value}
			</span>

			<button
				type="button"
				title="Aumentar"
				disabled={!canIncrease}
				onClick={() => onChange(value + 1)}
				className={cn(
					step,
					canIncrease
						? "text-white/50 hover:bg-white/10 hover:text-white"
						: "cursor-not-allowed text-white/15",
				)}
			>
				<IconPlus stroke={3} className="size-[.875rem]" />
			</button>
		</div>
	);
}
