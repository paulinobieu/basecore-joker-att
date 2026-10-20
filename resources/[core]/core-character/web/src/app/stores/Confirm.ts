import { create } from "zustand";

export interface ConfirmRequest {
	message: string;
	header?: string;
	acceptLabel?: string;
	rejectLabel?: string;
	accept?: () => void | Promise<void>;
	reject?: () => void | Promise<void>;
}

interface ConfirmStore {
	request: ConfirmRequest | null;
}

interface ConfirmActions {
	/** Abre a confirmacao. Substitui a que estiver aberta. */
	require: (request: ConfirmRequest) => void;
	accept: () => void;
	reject: () => void;
}

export const useConfirmStore = create<ConfirmStore & ConfirmActions>()(
	(set, get) => ({
		request: null,

		require: (request) => set({ request }),

		accept: () => {
			const { request } = get();

			set({ request: null });
			request?.accept?.();
		},

		reject: () => {
			const { request } = get();

			set({ request: null });
			request?.reject?.();
		},
	}),
);

/** Atalho para uso fora de componentes, no estilo do useConfirm. */
export const confirm = {
	require: (request: ConfirmRequest) =>
		useConfirmStore.getState().require(request),
};
