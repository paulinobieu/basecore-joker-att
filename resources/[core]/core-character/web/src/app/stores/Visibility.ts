import { ACTIONS } from "@app/constants/callbacks";
import { nuiAction } from "@app/utils/fetchNui";
import { create } from "zustand";

interface VisibilityStore {
	visible: boolean;
	/** So libera as telas depois que o setup do client chegou. */
	ready: boolean;
}

interface VisibilityActions {
	setVisible: (value: boolean) => void;
	setReady: (value: boolean) => void;

	/**
	 * Esconde a interface sem falar com o client — para quando a acao
	 * seguinte (selecionar, spawnar, salvar) ja tira o foco por conta.
	 */
	hide: () => void;

	/** Esconde e pede ao client para devolver o foco ao jogo. */
	requestClose: () => Promise<void>;
}

export const useVisibilityStore = create<VisibilityStore & VisibilityActions>()(
	(set, get) => ({
		visible: false,
		ready: false,

		setVisible: (visible) => set({ visible }),
		setReady: (ready) => set({ ready }),

		hide: () => set({ visible: false }),

		requestClose: async () => {
			if (!get().visible) return;

			set({ visible: false });

			await nuiAction(ACTIONS.close, undefined, true);
		},
	}),
);
