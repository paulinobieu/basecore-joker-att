import { cn } from "@app/utils";
import { useId, useRef } from "react";

interface PinInputProps {
	label: string;
	value: string;
	onChange(value: string): void;
	invalid?: boolean;
}

const SLOTS = [0, 1, 2, 3];

/** Quatro casas com avanço automático — o PIN do banco tem tamanho fixo. */
export function PinInput({ label, value, onChange, invalid }: PinInputProps) {
	const groupId = useId().replace(/:/g, "");
	const slots = useRef<(HTMLInputElement | null)[]>([]);

	function write(index: number, typed: string) {
		const digit = typed.replace(/\D/g, "").slice(-1);
		if (!digit) return;

		onChange((value.slice(0, index) + digit).slice(0, 4));
		if (index < 3) slots.current[index + 1]?.focus();
	}

	function erase(index: number) {
		const target = value[index] ? index : Math.max(index - 1, 0);

		onChange(value.slice(0, target));
		slots.current[target]?.focus();
	}

	return (
		<div className="flex flex-col gap-[.375rem]">
			<span className="font-bold text-[.6875rem] text-ink-ghost uppercase tracking-wide">
				{label}
			</span>

			<div className="flex gap-[.5rem]">
				{SLOTS.map((index) => (
					<input
						key={`${groupId}-${index}`}
						ref={(element) => {
							slots.current[index] = element;
						}}
						type="password"
						inputMode="numeric"
						maxLength={1}
						value={value[index] ?? ""}
						onChange={(event) => write(index, event.target.value)}
						onKeyDown={(event) => {
							if (event.key !== "Backspace") return;
							event.preventDefault();
							erase(index);
						}}
						className={cn(
							"field h-[3rem] w-[3rem] text-center font-black text-[1.125rem] text-ink",
							invalid && "border-negative/60",
						)}
					/>
				))}
			</div>
		</div>
	);
}
