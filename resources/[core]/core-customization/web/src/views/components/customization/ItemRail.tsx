import { CATEGORY_ORDER, type CategoryKey } from "@app/constants/clothes";
import { fallbackItemIcon, itemIcons } from "@app/constants/icons";
import { useClothesStore } from "@app/stores/Clothes";
import { HexButton } from "@views/components/ui/HexButton";
import { Rail } from "@views/components/ui/Rail";
import { useMemo } from "react";

interface RailEntry {
	category: CategoryKey;
	key: string;
	icon: string;
	name: string;
}

/**
 * A trilha é uma lista única: cada hexágono é uma peça, não mais
 * categoria + subcategoria. A ordem mantém o agrupamento por região
 * (cabeça -> torso -> pernas) e ordena por nome dentro de cada uma.
 */
export function ItemRail() {
	const config = useClothesStore((state) => state.config);
	const activeCategory = useClothesStore((state) => state.activeCategory);
	const activeItem = useClothesStore((state) => state.activeItem);
	const select = useClothesStore((state) => state.select);

	const entries = useMemo<RailEntry[]>(() => {
		const list: RailEntry[] = [];

		for (const category of CATEGORY_ORDER) {
			const menus = config[category] ?? {};

			const keys = Object.keys(menus).sort((a, b) =>
				menus[a].infos.name
					.toUpperCase()
					.localeCompare(menus[b].infos.name.toUpperCase()),
			);

			for (const key of keys) {
				list.push({
					category,
					key,
					icon: menus[key].infos.icon,
					name: menus[key].infos.name,
				});
			}
		}

		return list;
	}, [config]);

	return (
		<Rail className="gap-1">
			{entries.map((entry) => {
				const Icon = itemIcons[entry.icon] ?? fallbackItemIcon;

				return (
					<button
						key={`${entry.category}:${entry.key}`}
						type="button"
						data-tooltip={entry.name}
						data-tooltip-position="right"
						onClick={() => select(entry.category, entry.key)}
					>
						<HexButton
							size={3.25}
							active={
								activeCategory === entry.category && activeItem === entry.key
							}
						>
							<Icon size={20} stroke={2} />
						</HexButton>
					</button>
				);
			})}
		</Rail>
	);
}
