import { type IBenefit, useBooster } from "@app/stores/Booster";
import { toArray } from "@app/utils/misc";
import { RewardItem } from "@views/components/RewardItem";

/** Duas linhas cheias e o que o card comporta; o resto fica no modal. */
const VISIBLE_REWARDS = 4;

export function Rewards({ benefit }: { benefit: IBenefit }) {
	const language = useBooster((state) => state.data?.language);

	if (!language) return null;

	const rewards = toArray(benefit.rewards);

	return (
		<section className="mt-[1.25rem] flex min-h-0 flex-1 flex-col">
			<span className="font-black text-[.6875rem] text-white/30 uppercase tracking-[.08em]">
				{language.rewardsLabel}
			</span>

			{rewards.length === 0 ? (
				<div className="mt-[.75rem] flex h-[4rem] w-full items-center justify-center rounded-[.375rem] border border-white/[.04] border-dashed font-semibold text-[.75rem] text-white/25">
					{language.empty}
				</div>
			) : (
				<div className="customScrollbar mt-[.75rem] grid min-h-0 flex-1 grid-cols-2 content-start gap-[.5rem] overflow-y-auto pr-[.25rem]">
					{rewards.slice(0, VISIBLE_REWARDS).map((reward) => (
						<RewardItem key={`${benefit.id}-${reward.id}`} reward={reward} />
					))}
				</div>
			)}
		</section>
	);
}
