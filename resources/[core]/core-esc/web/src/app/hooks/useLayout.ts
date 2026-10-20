import { useEscStore } from "@app/stores/Esc";
import { useVisibilityStore } from "@app/stores/Visibility";
import { useEffect } from "react";
import { useShallow } from "zustand/shallow";
import { useKeyPress } from "./useKeyPress";
import { useNuiMessage } from "./useNuiMessage";
import { useServerColors } from "./useServerColors";

export const useLayout = () => {
	const getEscData = useEscStore((state) => state.getEscData);

	const { visible, fetchHideFrame, setVisible } = useVisibilityStore(
		useShallow((state) => ({
			visible: state.visible,
			fetchHideFrame: state.fetchHideFrame,
			setVisible: state.setVisible,
		})),
	);

	useKeyPress("Escape", fetchHideFrame);
	useNuiMessage("setVisible", setVisible);

	useServerColors();

	// biome-ignore lint/correctness/useExhaustiveDependencies: <explanation>
	useEffect(() => {
		if (visible) getEscData();
	}, [visible, getEscData]);
};
