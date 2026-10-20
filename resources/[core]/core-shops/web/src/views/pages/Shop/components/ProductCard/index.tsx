import { useImageValidation } from "@app/hooks/useImageValidation";
import { useCart } from "@app/stores/Cart";
import type { IProduct } from "@app/stores/Shop";
import { cn } from "@app/utils";
import { formatMoney } from "@app/utils/misc";

interface ProductCardProps {
	product: IProduct;
	amountInCart: number;
}

/** O card inteiro e o botao: clicar joga mais uma unidade no carrinho. */
export function ProductCard({ product, amountInCart }: ProductCardProps) {
	const { imageUrl, onImageError } = useImageValidation(product.image);
	const addProduct = useCart((state) => state.addProduct);

	const inCart = amountInCart > 0;
	const soldOut = product.stock === 0;

	return (
		<button
			type="button"
			disabled={soldOut}
			title={soldOut ? "Produto esgotado" : `Adicionar ${product.name}`}
			onClick={() => addProduct(product)}
			className={cn(
				"surface-card flex flex-col rounded-[.3125rem] border border-solid p-[.75rem] text-left transition-colors duration-300",
				inCart ? "border-primaryColor/50" : "border-white/[.03]",
				soldOut ? "cursor-not-allowed opacity-50" : "hover:brightness-125",
			)}
		>
			<div className="accent-overlay" />

			<div className="relative z-30 flex h-full w-full flex-col">
				<h3
					title={product.name}
					className="w-full truncate font-black text-[#EDEAE5] text-[.8125rem] uppercase"
				>
					{product.name}
				</h3>

				<img
					src={imageUrl}
					alt={product.name}
					loading="lazy"
					decoding="async"
					onError={onImageError}
					className="my-[.75rem] h-[4.25rem] w-full object-contain"
				/>

				<div className="mt-auto flex items-center justify-between gap-2">
					<div className="flex flex-col">
						<span className="font-black text-[.5625rem] text-white/30 uppercase leading-none">
							Preço
						</span>
						<span className="font-black text-[.9375rem] text-primaryColor leading-tight">
							{formatMoney(product.price)}
						</span>
					</div>

					{soldOut ? (
						<span className="font-black text-[.625rem] text-white/35 uppercase">
							Esgotado
						</span>
					) : (
						inCart && (
							<span className="flex h-[1.5rem] items-center justify-center rounded-[.25rem] border border-white/15 border-solid px-2 font-black text-[.6875rem] text-white accent-btn">
								<span className="relative z-10">{amountInCart}x</span>
							</span>
						)
					)}
				</div>
			</div>
		</button>
	);
}
