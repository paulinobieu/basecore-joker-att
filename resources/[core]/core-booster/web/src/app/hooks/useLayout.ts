import { MOCK_COLORS } from "@app/mocks/booster";
import { useBooster } from "@app/stores/Booster";
import { useVisibilityStore } from "@app/stores/Visibility";
import { type ThemeColors, attributeColorsToHTML } from "@app/utils/colors";
import { fetchNui } from "@app/utils/fetchNui";
import { useEffect } from "react";
import { useShallow } from "zustand/shallow";
import { useKeyPress } from "./useKeyPress";
import { useNuiMessage } from "./useNuiMessage";

/**
 * Concentra o contrato com o Lua: tema, visibilidade do painel e a hidratacao
 * dos beneficios a cada abertura, porque boost e tag mudam fora da tela.
 */
export const useLayout = () => {
	const { visible, setVisible, fetchHideFrame } = useVisibilityStore(
		useShallow((state) => ({
			visible: state.visible,
			setVisible: state.setVisible,
			fetchHideFrame: state.fetchHideFrame,
		})),
	);

	const { preview, getBoosterData, closeRewards, clearStore } = useBooster(
		useShallow((state) => ({
			preview: state.preview,
			getBoosterData: state.getBoosterData,
			closeRewards: state.closeRewards,
			clearStore: state.clearStore,
		})),
	);

	// O ESC e um so: fecha a previa aberta antes de fechar o painel.
	useKeyPress("Escape", () => {
		if (preview) {
			closeRewards();
			return;
		}

		fetchHideFrame();
	});

	useNuiMessage<unknown>("setVisible", (payload) => setVisible(!!payload));

	useEffect(() => {
		fetchNui<{ colors: Partial<ThemeColors> } | null>({
			path: "booster:ready",
			mockData: { colors: MOCK_COLORS },
		}).then((result) => {
			if (result?.colors) attributeColorsToHTML(result.colors);
		});
	}, []);

	useEffect(() => {
		if (visible) {
			getBoosterData();
			return;
		}

		clearStore();
	}, [visible, getBoosterData, clearStore]);
};
