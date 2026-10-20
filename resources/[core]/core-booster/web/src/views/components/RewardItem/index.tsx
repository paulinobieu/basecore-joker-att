import { useImageValidation } from "@app/hooks/useImageValidation";
import { type IReward, useBooster } from "@app/stores/Booster";
import { formatNumber } from "@app/utils/misc";
import { IconLink } from "@tabler/icons-react";
import { Icon } from "@views/components/Icon";

/** Linha de recompensa. Serve tanto a previa do card quanto a lista do modal. */
export function RewardItem({ reward }: { reward: IReward }) {
	const language = useBooster((state) => state.data?.language);
	const { imageUrl, onImageError } = useImageValidation(reward.image);

	return (
		<div className="reward-card flex items-center gap-[.75rem] rounded-[.375rem] border border-white/[.05] border-solid p-[.5rem]">
			<div className="reward-thumb flex size-[2.5rem] flex-shrink-0 items-center justify-center rounded-[.25rem] p-[.3125rem]">
				{reward.image ? (
					<img
						src={imageUrl}
						alt={reward.label}
						onError={onImageError}
						className="relative z-10 max-h-full max-w-full object-contain"
					/>
				) : (
					<Icon
						icon={reward.icon}
						className="relative z-10 size-[1.125rem] text-cardColor"
					/>
				)}
			</div>

			<div className="flex min-w-0 flex-1 flex-col gap-[.125rem]">
				<span className="truncate font-black text-[#EDEAE5] text-[.75rem]">
					{reward.label}
				</span>

				{reward.linked ? (
					<span className="flex min-w-0 items-center gap-[.25rem] text-cardColor/70">
						<IconLink stroke={2} className="size-[.6875rem] flex-shrink-0" />
						<span className="truncate font-black text-[.625rem] uppercase">
							{language?.linked}
						</span>
					</span>
				) : reward.amount ? (
					<span className="truncate font-semibold text-[.6875rem] text-white/30">
						{formatNumber(reward.amount)}x
					</span>
				) : null}
			</div>
		</div>
	);
}
