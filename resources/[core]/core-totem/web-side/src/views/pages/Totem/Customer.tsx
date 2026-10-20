import type { OpenPayload, OrderEntry } from "@app/types/totem";
import { fetchNui } from "@app/utils/fetchNui";
import { Banner } from "@views/components/Banner";
import { OrderSummary } from "@views/components/OrderSummary";
import { ProductCard } from "@views/components/ProductCard";
import { useCallback, useMemo, useState } from "react";

export function Customer({ config }: { config: OpenPayload }) {
	const [cart, setCart] = useState<Record<string, number>>({});

	const updateQuantity = useCallback(
		(id: string, delta: number) => {
			setCart((currentCart) => {
				const item = config.items.find((entry) => entry.id === id);
				if (!item) return currentCart;
				const next = Math.min(
					config.maxPurchasePerItem,
					Math.max(0, (currentCart[id] ?? 0) + delta),
				);
				return { ...currentCart, [id]: next };
			});
		},
		[config.items, config.maxPurchasePerItem],
	);

	const totals = useMemo(() => {
		let count = 0;
		let total = 0;
		for (const item of config.items) {
			const quantity = cart[item.id] ?? 0;
			count += quantity;
			total += item.price * quantity;
		}
		return { count, total };
	}, [cart, config.items]);

	const confirmOrder = async () => {
		const order: OrderEntry[] = config.items.flatMap((item) => {
			const quantity = cart[item.id] ?? 0;
			return quantity > 0 ? [{ id: item.id, quantity }] : [];
		});
		if (order.length === 0) return;
		await fetchNui({
			path: "confirm",
			payload: { order },
			mockData: { ok: true },
		});
		setCart({});
	};

	return (
		<div className="flex h-full min-h-0 flex-col">
			<Banner image={config.banner} />
			<section className="menu-section">
				<h2 className="section-heading">Cardápio</h2>
				<div className="menu-list customScrollbar">
					{config.items.map((item) => (
						<ProductCard
							key={item.id}
							item={item}
							quantity={cart[item.id] ?? 0}
							maxQuantity={config.maxPurchasePerItem}
							currencyPrefix={config.currencyPrefix}
							currencySuffix={config.currencySuffix}
							currencySeparator={config.currencySeparator}
							onUpdate={updateQuantity}
						/>
					))}
				</div>
			</section>
			<OrderSummary
				count={totals.count}
				total={totals.total}
				currencyPrefix={config.currencyPrefix}
				currencySuffix={config.currencySuffix}
				currencySeparator={config.currencySeparator}
				onClear={() => setCart({})}
				onConfirm={confirmOrder}
			/>
		</div>
	);
}
