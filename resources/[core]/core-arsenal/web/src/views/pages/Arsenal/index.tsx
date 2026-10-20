import { ALL_CATEGORY, type IItem, useArsenal } from "@app/stores/Arsenal";
import { useLoadout } from "@app/stores/Loadout";
import { IconTargetOff } from "@tabler/icons-react";
import { Empty } from "@views/components/Empty";
import { useMemo } from "react";
import { useShallow } from "zustand/shallow";
import { ItemCard } from "./components/ItemCard";
import { Loadout } from "./components/Loadout";
import { Toolbar } from "./components/Toolbar";

const sorters: Record<string, (a: IItem, b: IItem) => number> = {
	cheapest: (a, b) => a.price - b.price,
	expensive: (a, b) => b.price - a.price,
	name: (a, b) => a.name.localeCompare(b.name),
};

export function Arsenal() {
	const { items, category, search, sort } = useArsenal(
		useShallow((state) => ({
			items: state.items,
			category: state.category,
			search: state.search,
			sort: state.sort,
		})),
	);

	const lines = useLoadout((state) => state.lines);

	const visibleItems = useMemo(() => {
		const term = search.trim().toLowerCase();

		return items
			.filter((item) => category === ALL_CATEGORY || item.category === category)
			.filter((item) => !term || item.name.toLowerCase().includes(term))
			.sort(sorters[sort] ?? sorters.cheapest);
	}, [items, category, search, sort]);

	return (
		<div className="flex h-full w-full">
			<section className="tactical-grid flex h-full flex-1 flex-col gap-[.9375rem] p-[1.25rem]">
				<div className="relative z-10 flex h-full flex-col gap-[.9375rem]">
					<Toolbar total={visibleItems.length} />

					<div className="customScrollbar flex-1 overflow-y-auto">
						{visibleItems.length === 0 ? (
							<Empty
								icon={IconTargetOff}
								label="Nenhum armamento encontrado"
								hint={
									search.trim()
										? "Tente outro termo de busca"
										: "Escolha outra seção acima"
								}
							/>
						) : (
							<div className="grid grid-cols-5 gap-[.75rem] pr-1">
								{visibleItems.map((item) => (
									<ItemCard
										key={`${item.category}:${item.id}`}
										item={item}
										amountInLoadout={
											lines.find((line) => line.id === item.id)?.amount ?? 0
										}
									/>
								))}
							</div>
						)}
					</div>
				</div>
			</section>

			<Loadout />
		</div>
	);
}
