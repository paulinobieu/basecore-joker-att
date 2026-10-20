import { useCart } from "@app/stores/Cart";
import { type IProduct, useShop } from "@app/stores/Shop";
import { IconPackageOff } from "@tabler/icons-react";
import { Empty } from "@views/components/Empty";
import { Loading } from "@views/components/SpinLoader";
import { useMemo } from "react";
import { useShallow } from "zustand/shallow";
import { Cart } from "./components/Cart";
import { ProductCard } from "./components/ProductCard";
import { Toolbar } from "./components/Toolbar";

const sorters: Record<string, (a: IProduct, b: IProduct) => number> = {
	cheapest: (a, b) => a.price - b.price,
	expensive: (a, b) => b.price - a.price,
	name: (a, b) => a.name.localeCompare(b.name),
};

export function Shop() {
	const { products, category, search, sort, status } = useShop(
		useShallow((state) => ({
			products: state.products,
			category: state.category,
			search: state.search,
			sort: state.sort,
			status: state.status,
		})),
	);

	const lines = useCart((state) => state.lines);

	const visibleProducts = useMemo(() => {
		const term = search.trim().toLowerCase();

		return products
			.filter((product) => category === "all" || product.category === category)
			.filter((product) => !term || product.name.toLowerCase().includes(term))
			.sort(sorters[sort] ?? sorters.cheapest);
	}, [products, category, search, sort]);

	return (
		<div className="flex h-full w-full">
			<section className="flex h-full flex-1 flex-col gap-[.9375rem] p-[1.25rem]">
				<Toolbar total={visibleProducts.length} />

				<div className="customScrollbar flex-1 overflow-y-auto">
					{status === "loading" ? (
						<Loading label="Carregando produtos" />
					) : visibleProducts.length === 0 ? (
						<Empty
							icon={IconPackageOff}
							label="Nenhum produto encontrado"
							hint={
								search.trim()
									? "Tente outro termo de busca"
									: "Escolha outra categoria acima"
							}
						/>
					) : (
						<div className="grid grid-cols-5 gap-[.75rem] pr-1">
							{visibleProducts.map((product) => (
								<ProductCard
									key={product.id}
									product={product}
									amountInCart={
										lines.find((line) => line.id === product.id)?.amount ?? 0
									}
								/>
							))}
						</div>
					)}
				</div>
			</section>

			<Cart />
		</div>
	);
}
