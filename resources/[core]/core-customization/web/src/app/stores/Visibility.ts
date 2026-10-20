import { create } from "zustand";

interface VisibilityStore {
	visible: boolean;
	/** Só libera as lojas depois que o catálogo de peças chegou. */
	ready: boolean;
}

interface VisibilityActions {
	setVisible: (value: boolean) => void;
	setReady: (value: boolean) => void;

	/**
	 * Esconde a interface sem falar com o client: toda saída daqui passa
	 * antes por salvar ou cancelar, e é o client que devolve o foco ao
	 * jogo ao fechar a loja.
	 */
	hide: () => void;
}

export const useVisibilityStore = create<VisibilityStore & VisibilityActions>()(
	(set) => ({
		visible: false,
		ready: false,

		setVisible: (visible) => set({ visible }),
		setReady: (ready) => set({ ready }),

		hide: () => set({ visible: false }),
	}),
);
