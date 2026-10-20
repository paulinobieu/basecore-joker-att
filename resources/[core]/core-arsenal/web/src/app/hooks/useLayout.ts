import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { type IRawCategory, useArsenal } from "@app/stores/Arsenal";
import { useLoadout } from "@app/stores/Loadout";
import { useVisibilityStore } from "@app/stores/Visibility";
import { attributeColorToHTML } from "@app/utils/colors";
import { useEffect } from "react";
import { useShallow } from "zustand/shallow";
import { useKeyPress } from "./useKeyPress";

/**
 * Concentra o contrato com o Lua. O client do arsenal manda o catalogo junto
 * com a abertura (`setArsenal` antes de `setVisible`), entao aqui nao existe
 * busca de dados -- a tela so recebe, e limpa tudo quando fecha.
 */
export const useLayout = () => {
	const { visible, setVisible, fetchHideFrame } = useVisibilityStore(
		useShallow((state) => ({
			visible: state.visible,
			setVisible: state.setVisible,
			fetchHideFrame: state.fetchHideFrame,
		})),
	);

	const { setArsenal, clearStore } = useArsenal(
		useShallow((state) => ({
			setArsenal: state.setArsenal,
			clearStore: state.clearStore,
		})),
	);

	const clearLoadout = useLoadout((state) => state.clearLoadout);

	useKeyPress("Escape", fetchHideFrame);

	useNuiMessage<unknown>("setVisible", (payload) => setVisible(!!payload));
	useNuiMessage<string>("setColor", attributeColorToHTML);
	useNuiMessage<IRawCategory[]>("setArsenal", setArsenal);

	useEffect(() => {
		if (visible) return;

		clearLoadout();
		clearStore();
	}, [visible, clearLoadout, clearStore]);
};
