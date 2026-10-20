import { type IBenefit, useBooster } from "@app/stores/Booster";
import { cn } from "@app/utils";
import { IconCheck } from "@tabler/icons-react";

/** Selos de estado do beneficio, na linha do titulo. */
export function Status({ benefit }: { benefit: IBenefit }) {
	const language = useBooster((state) => state.data?.language);

	if (!language) return null;

	return (
		<div className="flex min-w-0 items-center gap-[.375rem]">
			<div
				className={cn(
					"status-chip flex min-w-0 items-center gap-[.4375rem] rounded-[.1875rem] px-[.5rem] py-[.25rem]",
					!benefit.active && "is-off",
				)}
			>
				<span
					className={cn(
						"size-[.375rem] flex-shrink-0 rounded-full",
						benefit.active ? "bg-cardColor" : "bg-white/25",
					)}
				/>
				<span
					className={cn(
						"relative z-10 truncate font-black text-[.625rem] uppercase",
						benefit.active ? "text-cardColor" : "text-white/35",
					)}
				>
					{benefit.active ? benefit.labels.active : benefit.labels.inactive}
				</span>
			</div>

			{benefit.claimed && (
				<div className="claimed-badge flex flex-shrink-0 items-center gap-[.25rem] rounded-[.1875rem] px-[.5rem] py-[.25rem]">
					<IconCheck
						stroke={3}
						className="relative z-10 size-[.625rem] text-[#52FF97]"
					/>
					<span className="relative z-10 font-black text-[#52FF97] text-[.625rem] uppercase">
						{language.collected}
					</span>
				</div>
			)}
		</div>
	);
}
