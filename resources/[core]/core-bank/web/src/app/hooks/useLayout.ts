import { useBankStore } from "@app/stores/Bank";
import { useVisibilityStore } from "@app/stores/Visibility";
import { useEffect } from "react";
import { useShallow } from "zustand/shallow";
import { useKeyPress } from "./useKeyPress";
import { useNuiMessage } from "./useNuiMessage";
import { useServerColors } from "./useServerColors";

export const useLayout = () => {
	const { visible, fetchHideFrame, setVisible } = useVisibilityStore(
		useShallow((state) => ({
			visible: state.visible,
			fetchHideFrame: state.fetchHideFrame,
			setVisible: state.setVisible,
		})),
	);

	const refresh = useBankStore((state) => state.refresh);

	useKeyPress("Escape", fetchHideFrame);
	useNuiMessage<boolean>("setVisible", setVisible);

	// Abrir o banco sempre parte de dados frescos.
	useEffect(() => {
		if (!visible) return;

		refresh();
	}, [visible, refresh]);

	useServerColors();
};
