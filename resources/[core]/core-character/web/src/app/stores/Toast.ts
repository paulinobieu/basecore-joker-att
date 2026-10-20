import { create } from "zustand";

export type ToastSeverity = "success" | "info" | "warn" | "error";

export interface ToastMessage {
	id: number;
	severity: ToastSeverity;
	summary: string;
	detail?: string;
	life: number;
}

interface ToastStore {
	messages: ToastMessage[];
}

interface ToastActions {
	add: (message: Omit<ToastMessage, "id"> & { life?: number }) => void;
	remove: (id: number) => void;
}

let nextId = 0;

export const useToastStore = create<ToastStore & ToastActions>()((set) => ({
	messages: [],

	add: ({ severity, summary, detail, life = 5000 }) =>
		set((state) => ({
			messages: [
				...state.messages,
				{ id: ++nextId, severity, summary, detail, life },
			],
		})),

	remove: (id) =>
		set((state) => ({
			messages: state.messages.filter((message) => message.id !== id),
		})),
}));

/** Atalho para uso fora de componentes, no estilo do useToast. */
export const toast = {
	add: (message: Omit<ToastMessage, "id"> & { life?: number }) =>
		useToastStore.getState().add(message),
};
