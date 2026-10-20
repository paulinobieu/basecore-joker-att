import { useShallow } from "zustand/react/shallow";
import { useVisibility } from "@app/stores/Visibility";
import { useClickSound } from "./useClickSound";
import { useKeyPress } from "./useKeyPress";
import { useNuiMessage } from "./useNuiMessage";
import { useServerColors } from "./useServerColors";

export const useLayout = () => {
	const { fetchHideFrame, setVisible } = useVisibility(
		useShallow((s) => ({
			fetchHideFrame: s.fetchHideFrame,
			setVisible: s.setVisible,
		})),
	);

	useKeyPress("Escape", fetchHideFrame);
	useNuiMessage("setVisible", setVisible);
	useServerColors();
};
