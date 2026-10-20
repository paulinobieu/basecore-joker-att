import { useIsRendered } from "@app/hooks/useIsRendered";
import { AnimationProvider } from "@app/providers/Animation";
import { useShop } from "@app/stores/Shop";
import { useVisibilityStore } from "@app/stores/Visibility";
import { cn } from "@app/utils";
import { IconBuildingStore, IconX } from "@tabler/icons-react";
import { Hexagon } from "@views/components/Hexagon";
import { useShallow } from "zustand/shallow";

/**
 * Identificacao da loja e os corredores na mesma linha, como a placa de
 * secoes de um mercado.
 */
export function Topbar() {
	const { isRendered } = useIsRendered();
	const fetchHideFrame = useVisibilityStore((state) => state.fetchHideFrame);

	const { shop, categories, category, products, setCategory } = useShop(
		useShallow((state) => ({
			shop: state.shop,
			categories: state.categories,
			category: state.category,
			products: state.products,
			setCategory: state.setCategory,
		})),
	);

	return (
		<header className="flex h-[4.75rem] w-full flex-shrink-0 items-center gap-[1.25rem] border-[#D9D9D91A] border-b border-solid px-[1.25rem]">
			<AnimationProvider show={isRendered} className="flex items-center gap-3">
				<div className="relative flex size-[3.25rem] flex-shrink-0 items-center justify-center">
					<Hexagon active />
					<IconBuildingStore
						stroke={2}
						className="relative z-10 size-[1.25rem] text-white"
					/>
				</div>

				<div className="flex flex-col">
					<h1 className="whitespace-nowrap font-black text-[1.0625rem] text-white uppercase leading-tight">
						{shop?.label || "Loja"}
					</h1>
					<span className="whitespace-nowrap font-semibold text-[.6875rem] text-white/35">
						{shop?.subtitle || "Itens disponíveis"}
					</span>
				</div>
			</AnimationProvider>

			{categories.length > 0 && (
				<span className="h-[2.5rem] w-px flex-shrink-0 bg-white/[.08]" />
			)}

			<AnimationProvider
				show={isRendered}
				className="customScrollbar flex flex-1 items-center gap-[.5rem] overflow-x-auto"
			>
				{categories.map((item) => {
					const active = category === item.id;
					const total =
						item.id === "all"
							? products.length
							: products.filter((product) => product.category === item.id)
									.length;

					return (
						<button
							key={item.id}
							type="button"
							onClick={() => setCategory(item.id)}
							className={cn(
								"ghost-btn relative flex h-[2.5rem] flex-shrink-0 items-center gap-2 rounded-[.3125rem] border border-white/5 border-solid px-[1rem] transition-all duration-300",
								active && "is-active",
							)}
						>
							<span
								className={cn(
									"relative z-10 font-black text-[.75rem] uppercase transition-all duration-300",
									active ? "text-white" : "text-[#EDEAE599]",
								)}
							>
								{item.label}
							</span>
							<span
								className={cn(
									"relative z-10 font-black text-[.625rem]",
									active ? "text-white/60" : "text-white/25",
								)}
							>
								{total}
							</span>
						</button>
					);
				})}
			</AnimationProvider>

			<AnimationProvider show={isRendered}>
				<button
					type="button"
					title="Fechar (ESC)"
					onClick={fetchHideFrame}
					className="ghost-btn relative flex size-[2.5rem] items-center justify-center rounded-[.3125rem] border border-white/5 border-solid text-white/45 transition-all duration-300 hover:text-white"
				>
					<IconX stroke={2.5} className="relative z-10 size-[1.125rem]" />
				</button>
			</AnimationProvider>
		</header>
	);
}
