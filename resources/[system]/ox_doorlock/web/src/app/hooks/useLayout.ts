import { useVisibilityStore } from "@app/stores/Visibility";
import { useShallow } from "zustand/shallow";
import { useKeyPress } from "./useKeyPress";
import { useNuiMessage } from "./useNuiMessage";

export const useLayout = () => {
	const { fetchHideFrame, setVisible } = useVisibilityStore(
		useShallow((state) => ({
			fetchHideFrame: state.fetchHideFrame,
			setVisible: state.setVisible,
		})),
	);

	useKeyPress("Escape", fetchHideFrame);
	useNuiMessage("setVisible", setVisible);
};
