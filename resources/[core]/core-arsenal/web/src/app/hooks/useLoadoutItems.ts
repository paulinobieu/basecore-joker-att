import { type IItem, useArsenal } from "@app/stores/Arsenal";
import { useLoadout } from "@app/stores/Loadout";
import { useMemo } from "react";

export interface ILoadoutItem {
	item: IItem;
	amount: number;
	total: number;
}

/**
 * Junta as linhas da requisicao com o catalogo. O preco sempre vem do item,
 * nunca da linha -- o servidor recalcula tudo na hora de autorizar.
 */
export const useLoadoutItems = () => {
	const lines = useLoadout((state) => state.lines);
	const items = useArsenal((state) => state.items);

	return useMemo(() => {
		const list: ILoadoutItem[] = [];

		for (const line of lines) {
			const item = items.find((entry) => entry.id === line.id);
			if (!item) continue;

			list.push({
				item,
				amount: line.amount,
				total: item.price * line.amount,
			});
		}

		const amount = list.reduce((sum, entry) => sum + entry.amount, 0);
		const total = list.reduce((sum, entry) => sum + entry.total, 0);

		return { list, amount, total };
	}, [lines, items]);
};
