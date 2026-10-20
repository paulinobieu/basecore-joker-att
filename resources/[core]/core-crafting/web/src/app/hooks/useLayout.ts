import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { type ICraftingUpdate, useCrafting } from "@app/stores/Crafting";
import { useVisibilityStore } from "@app/stores/Visibility";
import { type ThemeColors, attributeColorsToHTML } from "@app/utils/colors";
import { useEffect } from "react";
import { useShallow } from "zustand/shallow";
import { useKeyPress } from "./useKeyPress";

/**
 * Concentra o contrato com o Lua: visibilidade, tema, hidratacao da bancada e
 * as atualizacoes de inventario e fila enquanto o painel esta aberto.
 */
export const useLayout = () => {
	const { visible, setVisible, fetchHideFrame } = useVisibilityStore(
		useShallow((state) => ({
			visible: state.visible,
			setVisible: state.setVisible,
			fetchHideFrame: state.fetchHideFrame,
		})),
	);

	const { getCraftingData, applyUpdate, clearStore } = useCrafting(
		useShallow((state) => ({
			getCraftingData: state.getCraftingData,
			applyUpdate: state.applyUpdate,
			clearStore: state.clearStore,
		})),
	);

	useKeyPress("Escape", fetchHideFrame);

	useNuiMessage<unknown>("setVisible", (payload) => setVisible(!!payload));
	useNuiMessage<Partial<ThemeColors>>("craft:setColors", attributeColorsToHTML);
	useNuiMessage<ICraftingUpdate>("craft:update", applyUpdate);

	useEffect(() => {
		if (visible) {
			getCraftingData();
			return;
		}

		clearStore();
	}, [visible, getCraftingData, clearStore]);
};
