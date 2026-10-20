import { useNuiMessage } from "@app/hooks/useNuiMessage";
import { useCart } from "@app/stores/Cart";
import { useShop } from "@app/stores/Shop";
import { useVisibilityStore } from "@app/stores/Visibility";
import { type ThemeColors, attributeColorsToHTML } from "@app/utils/colors";
import { useEffect } from "react";
import { useShallow } from "zustand/shallow";
import { useKeyPress } from "./useKeyPress";

/**
 * Concentra o contrato com o Lua: visibilidade, tema, hidratacao da loja e
 * limpeza do carrinho ao fechar.
 */
export const useLayout = () => {
	const { visible, setVisible, fetchHideFrame } = useVisibilityStore(
		useShallow((state) => ({
			visible: state.visible,
			setVisible: state.setVisible,
			fetchHideFrame: state.fetchHideFrame,
		})),
	);

	const { getShopData, clearStore } = useShop(
		useShallow((state) => ({
			getShopData: state.getShopData,
			clearStore: state.clearStore,
		})),
	);

	const clearCart = useCart((state) => state.clearCart);

	useKeyPress("Escape", fetchHideFrame);

	useNuiMessage<unknown>("setVisible", (payload) => setVisible(!!payload));
	useNuiMessage<Partial<ThemeColors>>("shop:setColors", attributeColorsToHTML);

	useEffect(() => {
		if (visible) {
			getShopData();
			return;
		}

		clearCart();
		clearStore();
	}, [visible, getShopData, clearCart, clearStore]);
};
