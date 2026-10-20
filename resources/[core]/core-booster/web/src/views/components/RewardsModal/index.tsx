import { useBooster } from "@app/stores/Booster";
import { accentVars } from "@app/utils/colors";
import { toArray } from "@app/utils/misc";
import { IconX } from "@tabler/icons-react";
import { Hexagon } from "@views/components/Hexagon";
import { Icon } from "@views/components/Icon";
import { RewardItem } from "@views/components/RewardItem";
import type { CSSProperties } from "react";
import { useShallow } from "zustand/shallow";

/** Lista completa do que o beneficio entrega. E so leitura: quem paga e o servidor. */
export function RewardsModal() {
	const { language, preview, closeRewards } = useBooster(
		useShallow((state) => ({
			language: state.data?.language,
			preview: state.preview,
			closeRewards: state.closeRewards,
		})),
	);

	if (!language || !preview) return null;

	const rewards = toArray(preview.rewards);

	return (
		<div className="modal-overlay absolute inset-0 z-[10] flex items-center justify-center rounded-[.625rem]">
			<div
				style={accentVars(preview.accent) as CSSProperties}
				className="modal-panel flex w-[32rem] flex-col rounded-[.5rem] border border-white/10 border-solid p-[1.25rem]"
			>
				<header className="flex items-center gap-[.875rem]">
					<Hexagon size={2.75}>
						<Icon icon={preview.icon} className="size-[1.0625rem] text-white" />
					</Hexagon>

					<div className="flex min-w-0 flex-1 flex-col">
						<span className="font-black text-[.6875rem] text-white/30 uppercase tracking-[.08em]">
							{language.rewardsLabel}
						</span>
						<h2 className="truncate font-black text-[.9375rem] text-white uppercase">
							{preview.title}
						</h2>
					</div>

					<button
						type="button"
						title={language.close}
						onClick={closeRewards}
						className="flex size-[1.5rem] flex-shrink-0 items-center justify-center text-white/40 transition-all duration-300 hover:text-white"
					>
						<IconX stroke={2} className="size-[1rem]" />
					</button>
				</header>

				{rewards.length === 0 ? (
					<div className="flex h-[8rem] w-full items-center justify-center font-semibold text-[.8125rem] text-white/25">
						{language.empty}
					</div>
				) : (
					<div className="customScrollbar mt-[1rem] grid max-h-[22rem] grid-cols-2 gap-[.5rem] overflow-y-auto pr-[.25rem]">
						{rewards.map((reward) => (
							<RewardItem key={`${preview.id}-${reward.id}`} reward={reward} />
						))}
					</div>
				)}
			</div>
		</div>
	);
}
