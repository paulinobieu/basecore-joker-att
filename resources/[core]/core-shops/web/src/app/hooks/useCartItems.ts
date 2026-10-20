import { useCart } from "@app/stores/Cart";
import { type IProduct, useShop } from "@app/stores/Shop";
import { useMemo } from "react";

export interface ICartItem {
	product: IProduct;
	amount: number;
	total: number;
}

/**
 * Junta as linhas do carrinho com o catalogo. O preco sempre vem do produto,
 * nunca do carrinho -- o servidor recalcula tudo no checkout.
 */
export const useCartItems = () => {
	const lines = useCart((state) => state.lines);
	const products = useShop((state) => state.products);

	return useMemo(() => {
		const items: ICartItem[] = [];

		for (const line of lines) {
			const product = products.find((item) => item.id === line.id);
			if (!product) continue;

			items.push({
				product,
				amount: line.amount,
				total: product.price * line.amount,
			});
		}

		const amount = items.reduce((sum, item) => sum + item.amount, 0);
		const total = items.reduce((sum, item) => sum + item.total, 0);

		return { items, amount, total };
	}, [lines, products]);
};
