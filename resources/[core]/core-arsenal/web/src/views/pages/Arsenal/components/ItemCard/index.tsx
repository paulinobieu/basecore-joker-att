import { useImageValidation } from "@app/hooks/useImageValidation";
import type { IItem } from "@app/stores/Arsenal";
import { useLoadout } from "@app/stores/Loadout";
import { cn } from "@app/utils";
import { formatMoney } from "@app/utils/misc";
import { Detail } from "@views/components/Detail";

interface ItemCardProps {
	item: IItem;
	amountInLoadout: number;
}

/** O card inteiro e o botao: clicar joga mais uma unidade na requisicao. */
export function ItemCard({ item, amountInLoadout }: ItemCardProps) {
	const { imageUrl, onImageError } = useImageValidation(item.image);
	const addItem = useLoadout((state) => state.addItem);

	const selected = amountInLoadout > 0;

	return (
		<button
			type="button"
			title={`Requisitar ${item.name}`}
			onClick={() => addItem(item)}
			className={cn(
				"surface-card plate-seam flex flex-col rounded-[.1875rem] border border-solid p-[.75rem] text-left transition-colors duration-300 hover:brightness-125",
				selected ? "border-primaryColor/50" : "border-white/[.04]",
			)}
		>
			<div className="accent-overlay" />
			<Detail active={selected} />

			<div className="relative z-30 flex h-full w-full flex-col">
				<div className="flex items-start justify-between gap-2">
					<h3
						title={item.name}
						className="stencil w-full truncate text-[#EDEAE5] text-[.8125rem]"
					>
						{item.name}
					</h3>
				</div>

				<span className="mt-[.125rem] truncate font-semibold text-[.5625rem] text-white/25">
					{item.category}
				</span>

				<img
					src={imageUrl}
					alt={item.name}
					loading="lazy"
					decoding="async"
					onError={onImageError}
					className="my-[.75rem] h-[4.25rem] w-full object-contain"
				/>

				<div className="mt-auto flex items-center justify-between gap-2">
					<div className="flex flex-col">
						<span className="stencil text-[.5625rem] text-white/30 leading-none">
							Custo
						</span>
						<span className="font-black text-[.9375rem] text-primaryColor tabular-nums leading-tight">
							{formatMoney(item.price)}
						</span>
					</div>

					{selected && (
						<span className="flex h-[1.5rem] items-center justify-center rounded-[.125rem] border border-white/15 border-solid px-2 font-black text-[.6875rem] text-white tabular-nums accent-btn">
							<span className="relative z-10">{amountInLoadout}x</span>
						</span>
					)}
				</div>
			</div>
		</button>
	);
}
