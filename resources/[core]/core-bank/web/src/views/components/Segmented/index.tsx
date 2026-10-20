import { cn } from "@app/utils";
import type { ReactNode } from "react";

export interface SegmentedOption<T extends string> {
	value: T;
	label: string;
	icon?: ReactNode;
}

/** Impede que o `onChange` participe da inferência e alargue T para string. */
type NoInfer<T> = [T][T extends unknown ? 0 : never];

interface SegmentedProps<T extends string> {
	options: SegmentedOption<T>[];
	value: T;
	onChange(value: NoInfer<T>): void;
	/** Divide a largura em partes iguais. Exige um track de largura definida. */
	stretch?: boolean;
	className?: string;
}

/**
 * Alternador curto (período do gráfico, depositar/sacar, abas da conta).
 *
 * Sem `stretch` cada item ocupa o tamanho do próprio rótulo — é o que serve
 * para filtros dentro do cabeçalho de um card. Com `stretch` os itens dividem
 * a largura ao meio: o `min-w-0` é o que impede o rótulo mais longo de puxar
 * espaço do vizinho e desalinhar as metades.
 */
export function Segmented<T extends string>({
	options,
	value,
	onChange,
	stretch,
	className,
}: SegmentedProps<T>) {
	return (
		<div
			className={cn(
				"filter-bar flex h-[2.25rem] flex-shrink-0 items-center gap-[.1875rem] rounded-[.3125rem] border border-white/[.06] border-solid p-[.1875rem]",
				className,
			)}
		>
			{options.map((option) => {
				const active = option.value === value;

				return (
					<button
						key={option.value}
						type="button"
						onClick={() => onChange(option.value)}
						className={cn(
							"ghost-btn flex h-full items-center justify-center gap-[.375rem] whitespace-nowrap rounded-[.25rem] px-[.75rem] font-black text-[.6875rem] uppercase leading-none transition-all duration-300",
							stretch && "min-w-0 flex-1",
							active
								? "is-active text-white"
								: "text-ink-ghost hover:text-ink-faint",
						)}
					>
						{option.icon}
						<span className="relative z-10">{option.label}</span>
					</button>
				);
			})}
		</div>
	);
}
