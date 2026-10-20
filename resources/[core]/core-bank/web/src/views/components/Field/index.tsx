import type { Icon } from "@tabler/icons-react";
import { cn } from "@app/utils";
import type { InputHTMLAttributes, ReactNode } from "react";

interface FieldProps extends InputHTMLAttributes<HTMLInputElement> {
	label: string;
	/** Informação curta alinhada à direita do rótulo (saldo disponível, limite). */
	aside?: ReactNode;
	hint?: string;
	icon?: Icon;
	prefix?: string;
	invalid?: boolean;
}

export function Field({
	label,
	aside,
	hint,
	icon: FieldIcon,
	prefix,
	invalid,
	className,
	...props
}: FieldProps) {
	return (
		<label className="flex w-full min-w-0 flex-col gap-[.375rem]">
			<span className="flex items-baseline justify-between gap-[.5rem]">
				<span className="truncate font-bold text-[.6875rem] text-ink-ghost uppercase tracking-wide">
					{label}
				</span>
				{aside}
			</span>

			<div
				className={cn(
					"field flex h-[2.75rem] items-center gap-[.5rem] px-[.75rem]",
					invalid && "border-negative/60",
				)}
			>
				{FieldIcon && (
					<FieldIcon
						stroke={2.5}
						className="size-[.875rem] flex-shrink-0 text-white/25"
					/>
				)}
				{prefix && (
					<span className="flex-shrink-0 font-black text-[.875rem] text-white/35">
						{prefix}
					</span>
				)}

				<input
					{...props}
					className={cn(
						"h-full w-full min-w-0 bg-transparent font-bold text-[.875rem] text-ink outline-none placeholder:font-semibold placeholder:text-white/20",
						className,
					)}
				/>
			</div>

			{hint && (
				<span className="truncate font-semibold text-[.6875rem] text-white/25">
					{hint}
				</span>
			)}
		</label>
	);
}
