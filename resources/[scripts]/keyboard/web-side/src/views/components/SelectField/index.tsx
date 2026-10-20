import { cn } from "@app/utils";
import { useEffect, useRef, useState } from "react";

interface Option {
	Label: string;
	Value: string;
}

interface SelectFieldProps {
	options: Option[];
	value: string;
	placeholder: string;
	hasError: boolean;
	onChange: (value: string) => void;
}

export function SelectField({ options, value, placeholder, hasError, onChange }: SelectFieldProps) {
	const [open, setOpen] = useState(false);
	const ref = useRef<HTMLDivElement>(null);

	useEffect(() => {
		const handler = (e: MouseEvent) => {
			if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
		};
		document.addEventListener("mousedown", handler);
		return () => document.removeEventListener("mousedown", handler);
	}, []);

	const selected = options.find((o) => o.Value === value);

	return (
		<div className="relative w-full" ref={ref} style={{ zIndex: open ? 9999 : 'auto' }}>
			<button
				type="button"
				className={cn(
					"flex h-[2.625rem] w-full items-center justify-between rounded-lg border bg-white/[.04] px-3.5 text-xs font-medium transition-colors",
					hasError ? "border-red-500" : open ? "border-white/15" : "border-white/10 hover:border-white/15",
				)}
				onClick={() => setOpen(!open)}
			>
				<span className={selected ? "truncate text-white" : "text-white/35"}>
					{selected ? selected.Label : placeholder}
				</span>
				<svg
					className={cn("h-3 w-3 shrink-0 text-white/30 transition-transform duration-200", open && "rotate-180")}
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					strokeWidth="2.5"
					strokeLinecap="round"
					strokeLinejoin="round"
				>
					<polyline points="6 9 12 15 18 9" />
				</svg>
			</button>

			{open && (
				<div className="kb-dropdown scrollbar-thin">
					{options.map((opt, i) => (
						<button
							type="button"
							key={i}
							className={cn(
								"rounded-lg px-3 py-2 text-left text-xs font-medium transition-colors",
								opt.Value === value
									? "bg-white/[.08] text-white"
									: "text-white/60 hover:bg-white/[.05] hover:text-white/90",
							)}
							onClick={() => {
								onChange(opt.Value);
								setOpen(false);
							}}
						>
							{opt.Label}
						</button>
					))}
				</div>
			)}
		</div>
	);
}
