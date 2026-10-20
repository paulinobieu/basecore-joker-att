import type { MenuSection, SubMenuItem } from "@app/constants/menus";
import { useCallback, useMemo, useState } from "react";

function defaultMenus(menus: Record<string, MenuSection>) {
	return Object.fromEntries(
		Object.entries(menus).map(([key, section]) => [key, section.defaultMenu]),
	);
}

/**
 * Secao ativa (DNA, rosto, barbeiro, corpo) e qual submenu esta aberto
 * em cada uma — cada secao lembra onde o jogador parou.
 */
export function useCreatorMenus(menus: Record<string, MenuSection>) {
	const keys = useMemo(() => Object.keys(menus), [menus]);

	const [section, setSection] = useState(() => keys[0]);
	const [openMenus, setOpenMenus] = useState(() => defaultMenus(menus));

	const selectMenu = useCallback(
		(item: SubMenuItem) =>
			setOpenMenus((current) => ({ ...current, [section]: item.index })),
		[section],
	);

	const reset = useCallback(() => {
		setSection(keys[0]);
		setOpenMenus(defaultMenus(menus));
	}, [keys, menus]);

	const sectionData = menus[section] ?? menus[keys[0]];
	const activeMenu = openMenus[section] ?? sectionData.defaultMenu;

	return {
		section,
		sectionData,
		activeMenu,
		activeItem: sectionData.menus.find((item) => item.index === activeMenu),
		setSection,
		selectMenu,
		reset,
	};
}
