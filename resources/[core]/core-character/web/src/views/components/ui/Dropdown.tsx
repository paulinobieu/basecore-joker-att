import { cn } from "@app/utils";
import { IconChevronDown } from "@tabler/icons-react";
import { useEffect, useRef, useState } from "react";
import { Toggle } from "./Toggle";

export interface DropdownOption {
	index: string;
	name: string;
}

interface DropdownProps {
	options: DropdownOption[];
	value: DropdownOption | null;
	placeholder?: string;
	className?: string;
	onChange: (option: DropdownOption) => void;
}

export function Dropdown({
	options,
	value,
	placeholder = "Selecione",
	className,
	onChange,
}: DropdownProps) {
	const [open, setOpen] = useState(false);
	const rootRef = useRef<HTMLDivElement>(null);

	useEffect(() => {
		if (!open) return;

		const listener = (event: MouseEvent) => {
			if (rootRef.current?.contains(event.target as Node)) return;
			setOpen(false);
		};

		window.addEventListener("mousedown", listener);

		return () => window.removeEventListener("mousedown", listener);
	}, [open]);

	return (
		<div ref={rootRef} className={cn("relative", className)}>
			<button
				type="button"
				onClick={() => setOpen((current) => !current)}
				className={cn(
					"group flex w-full items-center justify-between rounded-field border bg-field bg-blend-screen",
					"transition-all duration-500 hover:border-primaryColor/40",
					open ? "border-primaryColor/40" : "border-white/[.08]",
				)}
			>
				<span
					className={cn(
						"px-3 py-2.5 font-black text-[.8125rem] uppercase",
						value ? "text-white" : "font-extrabold text-ink-ghost",
					)}
				>
					{value ? value.name : placeholder}
				</span>

				<span className="flex w-10 items-center justify-center text-ink-muted transition-colors duration-300 group-hover:text-white">
					<IconChevronDown size={16} stroke={2} />
				</span>
			</button>

			{open && (
				<div className="absolute top-full right-0 left-0 z-30 mt-1 flex flex-col gap-1 rounded-surface border border-white/[.06] bg-overlay p-1 shadow-overlay">
					{options.map((option) => (
						<Toggle
							key={option.index}
							active={value?.index === option.index}
							onClick={() => {
								onChange(option);
								setOpen(false);
							}}
							className="justify-start px-3 py-2 text-xs"
						>
							{option.name}
						</Toggle>
					))}
				</div>
			)}
		</div>
	);
}
