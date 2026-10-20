import { useTotemStore } from "@app/stores/Totem";
import { useVisibilityStore } from "@app/stores/Visibility";
import type { OpenPayload, UpdatePayload } from "@app/types/totem";
import { useKeyPress } from "./useKeyPress";
import { useNuiMessage } from "./useNuiMessage";

export function useLayout() {
	const fetchHideFrame = useVisibilityStore((state) => state.fetchHideFrame);
	const setVisible = useVisibilityStore((state) => state.setVisible);
	const openTotem = useTotemStore((state) => state.openTotem);
	const updateTotem = useTotemStore((state) => state.updateTotem);
	const clearTotem = useTotemStore((state) => state.clearTotem);

	useKeyPress("Escape", fetchHideFrame);
	useNuiMessage<boolean>("setVisible", (visible) => {
		setVisible(visible);
		if (!visible) clearTotem();
	});
	useNuiMessage<OpenPayload>("openTotem", openTotem);
	useNuiMessage<UpdatePayload>("updateTotemState", updateTotem);
}
