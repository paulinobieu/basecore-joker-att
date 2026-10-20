import { useNuiEvent } from "@app/hooks/useNuiEvent";
import { cn } from "@app/utils";
import { useState } from "react";

interface TipItem {
	key: string;
	label: string;
}

export function TipsOverlay() {
	const [tips, setTips] = useState<TipItem[]>([]);
	const [visible, setVisible] = useState(false);

	useNuiEvent<TipItem[]>("showTips", (data) => {
		setTips(data);
		setVisible(true);
	});

	useNuiEvent("hideTips", () => {
		setVisible(false);
		setTimeout(() => setTips([]), 300);
	});

	if (tips.length === 0 && !visible) return null;

	return (
		<div
			className={cn(
				"fixed bottom-8 left-1/2 z-[100] flex -translate-x-1/2 items-center gap-2 transition-all duration-300",
				visible
					? "translate-y-0 opacity-100"
					: "translate-y-4 opacity-0 pointer-events-none",
			)}
		>
			{tips.map((tip, i) => (
				<div
					key={`${tip.key}-${i}`}
					className="flex items-center gap-2.5 rounded-xl border border-white/[.07] bg-[rgb(12,12,12)] px-4 py-2.5 shadow-2xl"
				>
					<kbd className="flex h-8 min-w-[2.2rem] items-center justify-center rounded-lg border border-white/10 bg-white/[.06] px-2 font-bold text-[11px] uppercase tracking-wider text-white/90 shadow-[0_2px_0_rgba(255,255,255,0.05)]">
						{tip.key}
					</kbd>
					<span className="font-semibold text-[12px] tracking-wide text-white/50">
						{tip.label}
					</span>
				</div>
			))}
		</div>
	);
}
