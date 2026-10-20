interface KeyLabelProps {
	label: string;
}

export function KeyLabel({ label }: KeyLabelProps) {
	return (
		<div className="cursor-pointer rounded-[0.25rem] border-[0.7px] border-white/[.16] p-[0.125rem] transition-colors hover:border-white/[.25]">
			<div className="flex h-[1.625rem] w-[1.625rem] items-center justify-center rounded-[0.1875rem] border-[0.7px] border-white/[.06] bg-[#080808]/[.38] transition-colors hover:bg-[#080808]/[.55]">
				<span className="font-semibold text-[#F2F2F2] text-[0.8125rem] leading-none tracking-[-0.04em]">
					{label}
				</span>
			</div>
		</div>
	);
}
