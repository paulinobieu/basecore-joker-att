import type { MenuItem } from "@views/@types/menu";
import { useCallback, useEffect, useState } from "react";

export function useRadialMenu(
	items: MenuItem[],
	onAction: (item: MenuItem) => void,
	onClose: () => void,
) {
	const [levelStack, setLevelStack] = useState<MenuItem[][]>([items]);
	const [selectedIndex, setSelectedIndex] = useState(0);

	useEffect(() => {
		setLevelStack([items]);
		setSelectedIndex(0);
	}, [items]);

	const currentLevel = levelStack[levelStack.length - 1];
	const isNested = levelStack.length > 1;

	const handleSelect = useCallback((index: number) => {
		setSelectedIndex(index);
	}, []);

	const handleClick = useCallback(() => {
		const item = currentLevel[selectedIndex];
		if (!item) return;
		if (item.items?.length) {
			setLevelStack((prev) => [...prev, item.items!]);
			setSelectedIndex(0);
		} else {
			onAction(item);
		}
	}, [currentLevel, selectedIndex, onAction]);

	const handleCenterClick = useCallback(() => {
		if (isNested) {
			setLevelStack((prev) => prev.slice(0, -1));
			setSelectedIndex(0);
		} else {
			onClose();
		}
	}, [isNested, onClose]);

	useEffect(() => {
		const handler = (e: KeyboardEvent) => {
			if (e.key === "Escape" || e.key === "Backspace") {
				e.preventDefault();
				handleCenterClick();
			} else if (e.key === "Enter") {
				e.preventDefault();
				handleClick();
			}
		};
		document.addEventListener("keydown", handler);
		return () => document.removeEventListener("keydown", handler);
	}, [handleCenterClick, handleClick]);

	return {
		currentLevel,
		isNested,
		selectedIndex,
		handleSelect,
		handleClick,
		handleCenterClick,
	};
}
