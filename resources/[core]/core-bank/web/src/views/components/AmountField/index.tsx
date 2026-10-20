import { formatCurrency, parseAmount, sanitizeAmount } from "@app/utils/format";
import { cn } from "@app/utils";
import { Field } from "@views/components/Field";

const CHIPS = [100, 500, 1000, 5000];

interface AmountFieldProps {
	value: string;
	onChange(value: string): void;
	label?: string;
	/** Quando informado, mostra o teto e libera o atalho "tudo". */
	max?: number;
	maxLabel?: string;
}

/**
 * Campo de valor com atalhos. Somar em cima do que já está digitado é mais
 * rápido do que apagar e redigitar a cada tentativa.
 */
export function AmountField({
	value,
	onChange,
	label = "Valor",
	max,
	maxLabel = "Disponível",
}: AmountFieldProps) {
	const amount = parseAmount(value);
	const capped = typeof max === "number";
	const exceeded = capped && amount > max;

	function add(step: number) {
		const next = Math.round(amount + step);
		onChange(String(capped ? Math.min(next, Math.floor(max)) : next));
	}

	return (
		<div className="flex flex-col gap-[.5rem]">
			<Field
				label={label}
				prefix="$"
				placeholder="0"
				inputMode="numeric"
				value={value}
				invalid={exceeded}
				onChange={(event) => onChange(sanitizeAmount(event.target.value))}
				aside={
					capped ? (
						<span
							className={cn(
								"flex-shrink-0 whitespace-nowrap font-black text-[.6875rem]",
								exceeded ? "text-negative" : "text-ink-ghost",
							)}
						>
							{maxLabel} {formatCurrency(max)}
						</span>
					) : undefined
				}
			/>

			<div className="flex gap-[.375rem]">
				{CHIPS.map((chip) => (
					<button
						key={chip}
						type="button"
						onClick={() => add(chip)}
						className="row-surface h-[1.875rem] flex-1 font-black text-[.6875rem] text-ink-faint leading-none transition-all duration-300 hover:text-ink"
					>
						+{chip >= 1000 ? `${chip / 1000}k` : chip}
					</button>
				))}

				{capped && (
					<button
						type="button"
						onClick={() => onChange(String(Math.floor(max)))}
						className="row-surface h-[1.875rem] flex-1 font-black text-[.6875rem] text-primaryColor leading-none transition-all duration-300 hover:brightness-125"
					>
						Tudo
					</button>
				)}
			</div>
		</div>
	);
}
