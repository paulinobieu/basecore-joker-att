import type { ICartItem } from "@app/hooks/useCartItems";
import { useImageValidation } from "@app/hooks/useImageValidation";
import { useCart } from "@app/stores/Cart";
import { formatMoney } from "@app/utils/misc";
import { IconTrash } from "@tabler/icons-react";
import { Quantity } from "@views/components/Quantity";
import { useShallow } from "zustand/shallow";

export function CartLine({ product, amount, total }: ICartItem) {
	const { imageUrl, onImageError } = useImageValidation(product.image);

	const { setAmount, removeLine } = useCart(
		useShallow((state) => ({
			setAmount: state.setAmount,
			removeLine: state.removeLine,
		})),
	);

	return (
		<div className="cart-line-bar flex flex-shrink-0 items-center gap-[.5rem] rounded-[.3125rem] border border-white/[.03] border-solid p-[.5rem]">
			<img
				src={imageUrl}
				alt={product.name}
				loading="lazy"
				onError={onImageError}
				className="size-[2.5rem] flex-shrink-0 object-contain"
			/>

			<div className="flex min-w-0 flex-1 flex-col">
				<span
					title={product.name}
					className="truncate font-black text-[#EDEAE5] text-[.75rem] uppercase"
				>
					{product.name}
				</span>
				<span className="truncate font-semibold text-[.5625rem] text-white/30">
					{formatMoney(product.price)} cada
				</span>
			</div>

			<Quantity
				value={amount}
				max={product.stock < 0 ? undefined : product.stock}
				onChange={(value) => setAmount(product, value)}
			/>

			<span className="min-w-[4rem] flex-shrink-0 text-right font-black text-[.75rem] text-white">
				{formatMoney(total)}
			</span>

			<button
				type="button"
				title="Remover do carrinho"
				onClick={() => removeLine(product.id)}
				className="flex size-[1.25rem] flex-shrink-0 items-center justify-center rounded-[.25rem] text-white/25 transition-all duration-300 hover:text-white"
			>
				<IconTrash stroke={2} className="size-[.875rem]" />
			</button>
		</div>
	);
}
