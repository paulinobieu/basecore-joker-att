import {
	type EmoteItem,
	FAVORITES_CAT,
	useCreatorStore,
} from "@app/stores/CreatorStore";
import { useCallback, useEffect, useMemo, useRef } from "react";

export interface CategoryEntry {
	name: string;
	count: number;
}

function getFavoriteItems(
	groups: Record<string, EmoteItem[]>,
	favorites: string[],
): EmoteItem[] {
	const favSet = new Set(favorites);
	const out: EmoteItem[] = [];
	const seen = new Set<string>();

	for (const cat of Object.keys(groups)) {
		if (cat === FAVORITES_CAT) continue;
		for (const it of groups[cat] || []) {
			const cmd = String(it.command || "");
			if (cmd && favSet.has(cmd) && !seen.has(cmd)) {
				seen.add(cmd);
				out.push(it);
			}
		}
	}

	return out;
}

function itemsForCategory(
	cat: string | null,
	groups: Record<string, EmoteItem[]>,
	favorites: string[],
): EmoteItem[] {
	if (!cat) return [];
	if (cat === FAVORITES_CAT) return getFavoriteItems(groups, favorites);
	return groups[cat] || [];
}

export const useCreatorView = () => {
	const { groups, order, favorites, search, activeCat, setActiveCat } =
		useCreatorStore();

	const categories = useMemo<CategoryEntry[]>(() => {
		const names = new Set<string>();
		names.add(FAVORITES_CAT);
		for (const c of order) names.add(c);
		for (const c of Object.keys(groups)) names.add(c);

		return [...names].map((name) => ({
			name,
			count: itemsForCategory(name, groups, favorites).length,
		}));
	}, [groups, order, favorites]);

	const userPicked = useRef(false);

	const selectCat = useCallback(
		(cat: string) => {
			userPicked.current = true;
			setActiveCat(cat);
		},
		[setActiveCat],
	);

	// biome-ignore lint/correctness/useExhaustiveDependencies: <explanation>
	useEffect(() => {
		const names = categories.map((c) => c.name);
		const current = categories.find((c) => c.name === activeCat);
		const firstWithItems = categories.find((c) => c.count > 0);

		const invalid = !activeCat || !names.includes(activeCat);
		const autoEmpty =
			!userPicked.current && current?.count === 0 && !!firstWithItems;

		if (invalid || autoEmpty) {
			setActiveCat(firstWithItems?.name || names[0] || FAVORITES_CAT);
		}
	}, [categories]);

	const items = useMemo(() => {
		const list = itemsForCategory(activeCat, groups, favorites);
		const q = (search || "").toLowerCase().trim();
		if (!q) return list;

		return list.filter(
			(it) =>
				(it.label || "").toLowerCase().includes(q) ||
				(it.command || "").toLowerCase().includes(q),
		);
	}, [activeCat, groups, favorites, search]);

	return { categories, activeCat, items, setActiveCat: selectCat };
};
