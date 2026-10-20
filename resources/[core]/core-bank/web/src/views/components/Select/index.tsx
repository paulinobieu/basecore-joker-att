import { cn } from "@app/utils";
import { IconChevronDown } from "@tabler/icons-react";
import { useEffect, useRef, useState } from "react";

export interface SelectOption {
	value: string;
	label: string;
	hint?: string;
}

interface SelectProps {
	label: string;
	value: string;
	options: SelectOption[];
	onChange: (value: string) => void;
}

/** Dropdown do padrão da casa: gatilho com a mesma casca dos campos. */
export function Select({ label, value, options, onChange }: SelectProps) {
	const [open, setOpen] = useState(false);
	const root = useRef<HTMLDivElement | null>(null);

	useEffect(() => {
		if (!open) return;

		const onClick = (event: MouseEvent) => {
			if (!root.current?.contains(event.target as Node)) setOpen(false);
		};

		document.addEventListener("mousedown", onClick);
		return () => document.removeEventListener("mousedown", onClick);
	}, [open]);

	const selected = options.find((option) => option.value === value);

	return (
		<div
			ref={root}
			className="relative flex w-full min-w-0 flex-col gap-[.375rem]"
		>
			<span className="font-bold text-[.6875rem] text-ink-ghost uppercase tracking-wide">
				{label}
			</span>

			<button
				type="button"
				onClick={() => setOpen((state) => !state)}
				className="field flex h-[2.75rem] items-center justify-between gap-[.5rem] px-[.75rem]"
			>
				<span className="truncate font-bold text-[.875rem] text-ink">
					{selected?.label ?? "Selecionar"}
				</span>
				<IconChevronDown
					stroke={2.5}
					className={cn(
						"size-[.875rem] flex-shrink-0 text-white/30 transition-transform duration-300",
						open && "rotate-180",
					)}
				/>
			</button>

			{open && (
				<div className="customScrollbar absolute top-[4.25rem] z-30 flex max-h-[13rem] w-full flex-col gap-[.25rem] overflow-y-auto rounded-[.3125rem] border border-white/[.08] border-solid bg-[#151519] p-[.375rem]">
					{options.map((option) => (
						<button
							key={option.value}
							type="button"
							onClick={() => {
								onChange(option.value);
								setOpen(false);
							}}
							className={cn(
								"flex flex-col rounded-[.25rem] px-[.625rem] py-[.5rem] text-left transition-all duration-300",
								option.value === value
									? "bg-white/[.06]"
									: "hover:bg-white/[.03]",
							)}
						>
							<span className="truncate font-black text-[.75rem] text-ink leading-tight">
								{option.label}
							</span>
							{option.hint && (
								<span className="truncate font-semibold text-[.625rem] text-ink-ghost leading-tight">
									{option.hint}
								</span>
							)}
						</button>
					))}
				</div>
			)}
		</div>
	);
}
