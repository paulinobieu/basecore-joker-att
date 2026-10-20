import { useImageValidation } from "@app/hooks/useImageValidation";
import type { ILoadoutItem } from "@app/hooks/useLoadoutItems";
import { MAX_AMOUNT_PER_LINE, useLoadout } from "@app/stores/Loadout";
import { formatMoney } from "@app/utils/misc";
import { IconTrash } from "@tabler/icons-react";
import { Quantity } from "@views/components/Quantity";
import { useShallow } from "zustand/shallow";

export function LoadoutLine({ item, amount, total }: ILoadoutItem) {
	const { imageUrl, onImageError } = useImageValidation(item.image);

	const { setAmount, removeLine } = useLoadout(
		useShallow((state) => ({
			setAmount: state.setAmount,
			removeLine: state.removeLine,
		})),
	);

	return (
		<div className="requisition-bar flex flex-shrink-0 items-center gap-[.5rem] rounded-[.1875rem] border border-white/[.04] border-solid p-[.5rem]">
			<img
				src={imageUrl}
				alt={item.name}
				loading="lazy"
				onError={onImageError}
				className="size-[2.5rem] flex-shrink-0 object-contain"
			/>

			<div className="flex min-w-0 flex-1 flex-col">
				<span
					title={item.name}
					className="stencil truncate text-[#EDEAE5] text-[.75rem]"
				>
					{item.name}
				</span>
				<span className="truncate font-semibold text-[.5625rem] text-white/30">
					{formatMoney(item.price)} cada
				</span>
			</div>

			<Quantity
				value={amount}
				max={MAX_AMOUNT_PER_LINE}
				onChange={(value) => setAmount(item, value)}
			/>

			<span className="min-w-[4rem] flex-shrink-0 text-right font-black text-[.75rem] text-white tabular-nums">
				{formatMoney(total)}
			</span>

			<button
				type="button"
				title="Remover da requisição"
				onClick={() => removeLine(item.id)}
				className="flex size-[1.25rem] flex-shrink-0 items-center justify-center rounded-[.125rem] text-white/25 transition-all duration-300 hover:text-white"
			>
				<IconTrash stroke={2} className="size-[.875rem]" />
			</button>
		</div>
	);
}
