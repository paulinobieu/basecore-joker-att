import { useVisibilityStore } from "@app/stores/Visibility";
import { useShallow } from "zustand/shallow";
import { useNuiMessage } from "./useNuiMessage";
import { useServerColors } from "./useServerColors";

export const useLayout = () => {
	const { setVisible } = useVisibilityStore(
		useShallow((state) => ({
			setVisible: state.setVisible,
		})),
	);

	useNuiMessage("setVisible", setVisible);

	useServerColors();
};
