import type { Icon } from "@tabler/icons-react";

interface EmptyProps {
	icon: Icon;
	label: string;
	hint?: string;
}

export function Empty({ icon: EmptyIcon, label, hint }: EmptyProps) {
	return (
		<div className="flex h-full w-full flex-col items-center justify-center gap-2">
			<EmptyIcon stroke={1.5} className="size-[2.5rem] text-white/15" />
			<span className="font-black text-[.75rem] text-white/40 uppercase">
				{label}
			</span>
			{hint && (
				<span className="font-semibold text-[.6875rem] text-white/25">
					{hint}
				</span>
			)}
		</div>
	);
}
