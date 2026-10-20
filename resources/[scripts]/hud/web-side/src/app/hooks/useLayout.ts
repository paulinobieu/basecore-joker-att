import { fetchNui } from "@app/utils/fetchNui";
import { useMinimapDimensions } from "@app/stores/MinimapDimensions";
import { useVisibilityStore } from "@app/stores/Visibility";
import { useEffect } from "react";
import { useShallow } from "zustand/shallow";
import { useKeyPress } from "./useKeyPress";
import { useNuiMessage } from "./useNuiMessage";
import { useServerColors } from "./useServerColors";

export const useLayout = () => {
	const { visible, fetchHideFrame } = useVisibilityStore(
		useShallow((state) => ({
			visible: state.visible,
			fetchHideFrame: state.fetchHideFrame,
		})),
	);
	const getDimensions = useMinimapDimensions((state) => state.getDimensions);

	useKeyPress("Escape", fetchHideFrame);

	useServerColors();

	useNuiMessage("refetch:minimapDimensions", getDimensions);

	useEffect(() => {
		fetchNui({ path: "hud:ready", mockData: true });
	}, []);

	useEffect(() => {
		if (!visible) return;

		getDimensions();
	}, [visible, getDimensions]);
};
